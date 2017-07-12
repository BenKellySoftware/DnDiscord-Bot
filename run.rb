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

Bot.message(in: config["channel"]) do |event|
	message = event.content
	# Add the Async Form to each user who uses the bot
	event.user.extend(AsyncForms)
	if event.user.form
		if message.downcase.eql? "cancel"
			event.user.form = nil
		else
			event.user.form.enter(message, event)
		end
	elsif message.downcase.start_with? "create"
		params = message.split(" ").drop(1)
		puts params
		if params[0].downcase.eql? "player"
			event.user.form = Form.new(Forms[:player], "name")
			event.user.form.respond(event)
		end
		# Todo: Expand with other create forms
	elsif message.downcase.start_with? "roll"
		#Array of either XdY or X
		params = message[4..-1].delete(" ").split(/(?=[+-])/)
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
		if rolls.length > 0
			event.respond("Rolled #{rolls.join(", ")}")	
		end
		event.respond("Rolled a total of #{total}")
	elsif $players.keys.include? message.split(" ").first
		player = $players[message.split(" ").first]
		params = message.split(" ").drop(1)
		# checks if there are at least the 4 other required parameters first, then if the names are correct
		if params[3] and params[0].downcase.eql? "saving" and params[1].downcase.eql? "throw"
			event.respond(player.savingThrow(params[2], params[3].to_i))
		else
			event.respond("#{player.name} is a level #{player.level} #{player.race} #{player.class}")
		end
			
	else
		event.respond("Invalid Command")
	end
end

Bot.run