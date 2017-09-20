require 'discordrb'
require 'yaml'
require 'mongo'
require 'csv'
require_relative 'forms'
require_relative 'character'
require_relative 'roll'

config = YAML.load_file("config.yml")

$party = []

Client = Mongo::Client.new(config["connection-uri"])

#Test Character
# $party["Drizzt"] = Character.new("Drizzt Do'urden", "Drow", "Ranger")

Bot = Discordrb::Bot.new token: config["token"], client_id: config["client-id"]

module Player
	attr_accessor  :character
end

# Send a message, should return whatever response is, or nil
def commands(event)
	message = event.content
	if message.downcase.start_with? "create"
		params = params(message)
		# Always need to check if there are the right number of params
		if params[0] and params[0].downcase.eql? "character"
			return createCharacter(event)
		elsif params[0] and params[0].downcase.eql? "npc"
			return "I'm working on it, promise."
		elsif params[0] and params[0].downcase.eql? "creature"
			return "Still gonna be a while till this is working."
		else
			return "Create must be followed with either character, npc(TODO), or creature(TODO). So yeah, just character for now."
		end
		# Todo: Expand with other create forms

	elsif message.downcase.start_with? "roll"
		#params should be an array of either XdY or X
		params = message[4..-1].delete(" ").split(/(?=[+-])/)
		return rollMessage(params)

	elsif message.downcase.start_with? "load"
		return loadCharacter(event)
	# elsif $party.include? message.split(" ").first
	# 	character = $party[message.split(" ").first]
	# 	params = params(message)
	# 	return playerCommands(character, params)

	else
		return ["Invalid command", "What? Didn't understand that", 
			"Try again, but better this time.", "I don't think I can do whatever you said just yet", 
			"Either you typed in something wrong, or the devs have been to lazy to get that working",
			"Nothing found on that", "That's a mighty fine syntax error you got there!", "Nope",
			"I'm a D&D bot, you really think that makes any sense to me?", "I rolled a crit fail on my understanding of that",
			"Yeah, I could do that, I just don't wanna", "Could you phrase that another way, in Elvish maybe?"].sample
	end
end

def params(message)
	CSV::parse_line(message, {col_sep: ' '}).drop(1)
end

def createCharacter(event)
	event.user.form = Form.new(Forms["create character"], "fullName", event.user)
	return event.user.form.respond()
end

def loadCharacter(event)
	params = params(event.content)
	if !params[0]
		return "'Load' requires a name as a parameter"
	end
	event.user.extend(Player)
	if event.user.character
		return "You are already playing as #{event.user.character.name}. Type 'leave party' if you want to switch characters."
	end
	characterObj = Client['characters'].find({"name": params[0]}).first
	if characterObj
		character = Character.new(characterObj, event.user)
		event.user.character = character
		#List active party members
		$party.push(character)
		return "Welcome to the party #{character.fullName}"
	else
		return "A character with that shorthand name doesn't exist"
	end
end

def playerCommands(character, params)
	# checks if there are at least the 4 other required parameters first, then if the names are correct
	if params[3] and params[0].downcase.eql? "saving" and params[1].downcase.eql? "throw"
		return character.savingThrow(params[2], params[3].to_i)
	else
		return "#{character.name} is a level #{character.level} #{character.race} #{character.class}"
	end
end

Bot.message(in: config["channel"]) do |event|
	# Add the Async Form to each user who uses the bot
	event.channel.start_typing
	event.user.extend(AsyncForms)
	# If the user is currently in a form, limit the inputs to that
	if event.user.form
		message = event.content
		if message.downcase.eql? "cancel"
			event.user.form = nil
		else
			response = event.user.form.enter(message, event)
			# needs this cause will sometimes return nil and the command doesnt like that
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

begin
	Bot.run
rescue Interrupt, SystemExit
	Bot.stop
end