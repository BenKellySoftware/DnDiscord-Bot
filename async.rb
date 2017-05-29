require 'discordrb'
require 'yaml'

require_relative 'player'


config = YAML.load_file("config.yml")

Bot = Discordrb::Bot.new token: config["token"], client_id: config["client-id"]



# def CreatePlayerName (event, form={})
# 	event.respond("Name:")
# 	# event.message.await("CreatePlayerName") { |response|
# 	# 	form[:Name] = response.message.content
# 	# 	puts "Name: #{form[:Name]}"
# 	# 	CreatePlayerRace(response, form)
# 	# }
# end

# def CreatePlayerRace (event, form={})
# 	event.respond("Race:")
# 	event.message.await("CreatePlayerRace") { |response|
# 		form[:Race] = response.message.content
# 		puts "Race: #{form[:Race]}"
# 		CreatePlayerClass(response, form)
# 	}
# end

# def CreatePlayerClass (event, form={})
# 	event.respond("Class:")
# 	event.message.await("CreatePlayerClass") { |response|
# 		form[:Class] = response.message.content
# 		puts "Class: #{form[:Class]}"
# 		ConfirmPlayer(response, form)
# 	}
# end

# def ConfirmPlayer (event, form={})
# 	event.respond("Great! So to confirm, name is #{form[:Name]}, race is #{form[:Race]}, and class is #{form[:Class]}.
# 	\nType yes to confirm, or a field name to edit")

# 	event.message.await("CreatePlayerName") { |response|
# 		message = response.message.content.downcase
# 		if message.eql? "yes"
# 			event.respond("Creating Player...")
# 		elsif message.eql? "name"
# 			EditPlayerName(response, form)
# 		elsif message.eql? "race"
# 			EditPlayerRace(response, form)
# 		elsif message.eql? "class"
# 			EditPlayerClass(response, form)
# 		end	
# 	}
# end

# Races = {
# 	Aasimar
# 	Dragonborn
# 	Dwarf
# 	Elf
# 	Gnome
# 	Halfling
# 	Half-Elf
# 	Half-Orc
# 	Humam
# 	Tiefling
# }

Classes = {
	"Barbarian" => {

	},
	"Bard" => {

	},
	"Druid" => {

	},
	"Monk" => {

	},
	"Paladin" => {

	},
	"Ranger" => {

	},
	"Sorcerer" => {

	},
	"Warlock" => {

	}
}


Forms = {
	:player => {
		"name" => {
			"request" => "Name:",
			"next" => "race"
		},
		"race" => {
			"request" => "Race:",
			"next" => "class"
		},
		"class" => {
			"request" => "Class:",
			"next" =>	"confirm"
		},
		"confirm" => {
			"request" => "Type yes to confirm, or a field name to edit",
			"next" => nil
		},
		:submit => Proc.new do |responses|
  		puts Player.new(responses["name"], responses["race"], responses["class"])
  	end
	}
}

Bot.message(in: "dnd") do |event|
	message = event.content
	event.user.extend(AsyncForms)
	if event.user.form
		if message.downcase.eql? "cancel"
			event.user.form = nil
		else
			event.user.form.enter(message, event)
		end
	elsif message.downcase.start_with? "create player"
		event.user.form = Form.new(Forms[:player], "name")
		event.user.form.respond(event)
	else
		event.respond("Invalid Command")
	end
end

module AsyncForms
  attr_accessor :form
end

class Form
	def initialize(template, initField)
		@form = template
		@field = initField
		@responses = {}
	end

	def enter(response, event)
		if @field == 'confirm'
			if ['yes', 'y'].any? { |word| response.include?(word) }
				@form[:submit].call(@responses)
				# Delete Itself
				event.user.form = nil
			elsif @form.has_key? response.downcase
				@field = response.downcase	
				respond(event) 	 
			else
				event.respond("Invalid")
			end
		else
			@responses[@field] = response
			@field = @form[@field]["next"]
			respond(event)
		end
	end

	def respond(event)
		event.respond(@form[@field]["request"])
	end
end

# Discordrb::User.extend(AsyncForms)
Bot.run()