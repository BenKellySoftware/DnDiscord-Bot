require 'discordrb'
require 'yaml'
require_relative 'player'

config = YAML.load_file("config.yml")

players = {}

#Dice Rolls
def rollDouble(advantage)
	r1 = roll(20)
	r2 = roll(20)
	print "Rolled #{r1} and #{r2}, "
	if advantage
		puts "using #{[r1, r2].max}" 
		return [r1, r2].max
	else
		puts "using #{[r1, r2].min}" 
		return [r1, r2].min
	end
	
end

def roll (die)
	return 1 + Random.rand(die)
end

bot = Discordrb::Bot.new token: config["token"], client_id: config["client-id"]

bot.message(in: "dnd") do |event|
	if event.message.content.downcase.start_with? "create player"
		#Name, Class, Race, Alignment
		params = event.message.content[14..-1].split(", ");
		if params.length != 4
			event.respond("Not the correct number of parameters (need Name, Class, Race, Alignment)")
		else
			players[params[0].split(" ").first] = Player.new(params[0],params[1],params[2],params[3])
			event.respond("Created Player #{params[0].split(" ").first}")
		end
	elsif event.message.content.downcase.include? "roll"
		#Array of either XdY or X
		params = event.message.content[4..-1].delete(" ").split(/(?=[+-])/)
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
	else
		event.respond("Invalid Command")
	end

end

bot.run