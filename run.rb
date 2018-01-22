require 'discordrb'
require 'yaml'
require 'mongo'
require 'csv'
require 'titleize'
require_relative 'forms'
require_relative 'character'
require_relative 'roll'

config = YAML.load_file("config.yml")

$party = []

module UserEx
	attr_accessor  :character, :form
end

Client = Mongo::Client.new(config["connection-uri"])
Bot = Discordrb::Bot.new token: config["token"], client_id: config["client-id"]

Bot.message(in: config["channel"]) do |event|
	event.channel.start_typing
	# Add the Async Form to each user who uses the bot
	event.user.extend(UserEx)
	# If the user is currently in a form, limit the inputs to that
	if event.user.form
		message = event.content
		if message.downcase.eql? "cancel"
			event.user.form = nil
		else
			response = event.user.form.enter(message, event)
			if response
				event.respond(response)
			end
		end
	else
		response = commands(event)
		if response
			event.respond(response)
		end
	end
end

# Send a message, should return whatever response is, or nil
def commands(event)
	message = event.content
	if message.downcase.start_with? "create"
		params = params(message).drop(1)
		# Need to check if there are the right number of params
		if params[0]
			# Todo: Expand with other create forms
			if params[0].downcase.eql? "character"
				return createCharacter(event)
			elsif params[0].downcase.eql? "npc"
				return "I'm working on it, promise."
			elsif params[0].downcase.eql? "creature"
				return "Still gonna be a while till this is working."
			end
		end
		return "Create must be followed with either character, npc(TODO), or creature(TODO). So yeah, just character for now."

	elsif message.downcase.start_with? "load"
		return loadCharacter(event)

	elsif message.downcase.start_with? "roll"
		#params should be an array of either XdY or X
		params = message[4..-1].delete(" ").split(/(?=[+-])/)
		return rollMessage(params)

	elsif isGM?(event.user)
		# GM Commands
		params = params(message)
		character = $party.detect {|c| c.name.eql? params[0]}
		if character
			return playerCommands(character, params.drop(1))
		end
	elsif event.user.character
		return playerCommands(event.user.character, params(message))
	end
	# return errorMessage
end

def isGM? (user)
	user.roles.detect { |role| ["Game Master", "GM", "Dungeon Master", "DM"].include? role.name}
end

def errorMessage
	return ["Invalid command", "What? Didn't understand that", 
		"Try again, but better this time.", "I don't think I can do whatever you said just yet", 
		"Either you typed in something wrong, or the devs have been to lazy to get that working",
		"Nothing found on that", "That's a mighty fine syntax error you got there!", "Nope",
		"I'm a D&D bot, you really think that makes any sense to me?", "I rolled a crit fail on my understanding of that",
		"Yeah, I could do that, I just don't wanna", "Could you phrase that another way, in Elvish maybe?"].sample
end

def params(message)
	CSV::parse_line(message, {col_sep: ' '})
end

def createCharacter(event)
	event.user.form = Form.new(Forms["create character"], "fullName", event.user)
	return event.user.form.respond()
end

def loadCharacter(event)
	params = params(event.content).drop(1)
	if !params[0]
		return "'Load' requires a character name as a parameter"
	end
	if event.user.character
		return "You are already playing as #{event.user.character.name}. Type 'leave party' (TODO) if you want to switch characters."
	elsif $party.detect {|character| character.name.eql? params[0]}
		return "That character is alredy in the party"
	end
	characterObj = Client['characters'].find({"name": params[0]}).first
	if !characterObj
		return "A character with that shorthand name doesn't exist"
	end
	character = Character.new(characterObj, event.user)
	event.user.character = character
	#List active party members
	$party.push(character)
	return "Welcome to the party #{character.fullName}"
end

def playerCommands(character, params)
	if params[1] and params[0].downcase.eql? "proficiencies"
		if params[1].downcase.eql? "list"
			return character.listProficiencies
		elsif params[3] and params[1].downcase.eql? "add"
			return character.addProficiency(params[2].downcase, params[3].titleize)
		elsif params[3] and params[1].downcase.eql? "remove"
			return character.removeProficiency(params[2].downcase, params[3].titleize)
		end
	#Checks if there are at least the 3 other required parameters first, then if the names are correct
	elsif params[2] and params[0].downcase.eql? "save"
		return character.savingThrow(params[1], params[2].to_i)
	# elsif params[0] and params[0].downcase.eql? "summary"
	# 	return "#{character.name} is a level #{character.level} #{character.race} #{character.class}"
	end
end

begin
	Bot.run
rescue Interrupt, SystemExit
	Bot.stop
end