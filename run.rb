require 'discordrb'
require 'yaml'
require_relative 'forms'
require_relative 'player'
require_relative 'roll'

config = YAML.load_file("config.yml")

$players = {}

#Test Character
$players["Drizzt"] = Player.new("Drizzt Do'urden", "Drow", "Ranger")

Bot = Discordrb::Bot.new token: config["token"], client_id: config["client-id"]

# Send a message, should return whatever response is, or nil
def commands(event)
	message = event.content
	if message.downcase.start_with? "create"
		params = params(message)
		# Always need to check if there are the right number of params
		if params[0] and params[0].downcase.eql? "player"
			return createPlayer(event)
		elsif params[0] and params[0].downcase.eql? "npc"
			return "I'm working on it, promise."
		elsif params[0] and params[0].downcase.eql? "creature"
			return "Still gonna be a while till this is working."
		else
			return "Create must be followed with either player or npc(TODO), or creature(TODO). So yeah, just player for now."
		end
		# Todo: Expand with other create forms

	elsif message.downcase.start_with? "roll"
		#params should be an array of either XdY or X
		params = message[4..-1].delete(" ").split(/(?=[+-])/)
		return rollMessage(params)

	elsif $players.keys.include? message.split(" ").first
		player = $players[message.split(" ").first]
		params = params(message)
		return playerCommands(player, params)

	else
		return ["Invalid command", "What? Didn\'t understand that", 
			"Try again, but better this time.", "I don\'t think I can do whatever you said just yet", 
			"Either you typed in something wrong, or the devs have been to lazy to get that working",
			"Nothing found on that", "That's a mighty fine syntax error you got there!", "Nope",
			"I\'m a D&D bot, you really think that makes any sense to me?", "I rolled a crit fail on my understanding of that",
			"Yeah, I could do that, I just don't wanna", "Could you phrase that another way, in Elvish maybe?"].sample
	end
end

def params(message)
	message.split(" ").drop(1)
end

def createPlayer(event)
	event.user.form = Form.new(Forms[:player], "name")
	return event.user.form.respond()
end

def playerCommands(player, params)
	# checks if there are at least the 4 other required parameters first, then if the names are correct
	if params[3] and params[0].downcase.eql? "saving" and params[1].downcase.eql? "throw"
		return player.savingThrow(params[2], params[3].to_i)
	else
		return "#{player.name} is a level #{player.level} #{player.race} #{player.class}"
	end
end

def rollMessage(params)
	begin
		total = 0
		rolls = []
		params.each do |param|
			if param.include? "d"
				for i in 1..param.split("d").first.to_i
					roll = roll(param.split("d").last.to_i)
					rolls.push(roll)
					total += roll
				end
			else
				total += param.to_i
			end
		end
		return "Rolled #{rolls.join(", ")} for a total of #{total}"
	rescue
		return "Invalid roll, only include rolls or modifiers in the form XdY and X, with + or - in between"
	end
end

Bot.message(in: config["channel"]) do |event|

	# Add the Async Form to each user who uses the bot
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

Bot.run