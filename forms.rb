module AsyncForms
	attr_accessor  :form
end

Forms = {
	"create character" => {
		"fullName" => {
			"request" => "Full name:",
			"next" => "name"
		},
		"name" => {
			"request" => "The shorthand name I'll refer to you as:",
			"next" => "race",
			"validator" => Proc.new do |responses|
				if $client["characters"].find({"name" => responses["name"]}).count() > 0
					responses["errorMsg"] = "A character with that name exists"
					false
				else
					true
				end
			end
		},
		"race" => {
			"request" => "Race: \nType full race name, including subrace (e.g. High-Elf, Forest Gnome, Duergar etc.) \nType 'list' for a list of the races (TODO).",
			"next" => "abilities",
			"validator" => Proc.new do |responses|
				if responses["race"].downcase.eql? "list"
					responses["errorMsg"] = "TODO: List races"
					false
				else
					race = $client["races"].find({"name" => responses["race"]}).limit(1).first()
					if race
						responses["raceObj"] = race
						true
					else
						responses["errorMsg"] = "Race not found"
						false
					end
				end
			end
		},
		"abilities" => {
			"request" => "Ability Scores (raw numbers, pre-modifiers), write 6 numbers, comma seperated, between 1 and 20 in the order str,dex,con,int,wis,cha:",
			"next" => "class",
			"validator" => Proc.new do |responses|
					abilityArr = responses['abilities'].split(',').map(&:to_i)
					if abilityArr.length == 6 and abilityArr.all? { |ability| ability <= 20 }
						responses["abilityArr"] = abilityArr
						true
					else
						responses["errorMsg"] = "Invalid input"
						false
					end
			end
		},
		"class" => {
			"request" => "Class you want to take your first level in:",
			"next" =>	"background",
			"validator" => Proc.new do |responses|
				if responses["class"].downcase.eql? "list"
					responses["errorMsg"] = "TODO: List class"
					false
				else
					classObj = $client["classes"].find({"name" => responses["class"]}).limit(1).first()
					if classObj
						responses["classObj"] = classObj
						true
					else
						responses["errorMsg"] = "Class not found"
						false
					end
				end
			end
			# Should pull class info here and need to get hitdice and proficiencies when first level up run
		},
		"background" => {
			"request" => "Your characters background:",
			"next" => "confirm"
		},
		"confirm" => {
			"request" => "Type yes to move on and apply features, or a field name to edit:"
		},
		"proc" => true,
		"submit" => Proc.new do |responses|
			characterJSON = {
				"name" => responses["name"],
				"fullName" => responses["fullName"],
				"race" => responses["race"],
				"background" => responses["background"],
				"levels" => [{
					"name" => responses["class"],
					"level" => 0
				}],
				"abilities" => {
					"str" => responses['abilityArr'][0],
					"dex" => responses['abilityArr'][1],
					"con" => responses['abilityArr'][2],
					"int" => responses['abilityArr'][3],
					"wis" => responses['abilityArr'][4],
					"cha" => responses['abilityArr'][5]
				},
				"features" => []
				# will do a initial level up here 
			}
			characterJSON["features"].push responses["classObj"]['features']['1']
			$client['characters'].insert_one characterJSON
		end
	},
	'ability score improvement' => {
		"ability 1" => {
			"request" => "Ability One:",
			"next" => "ability 2"
		},
		"ability 2" => {
			"request" => "Ability Two:",
			"next" => "confirm"
		},
		"confirm" => {
			"request" => "Type yes to confirm, or a field name to edit:"
		},
		"submit" => "increase %1 1; increase %2 1;"
	}
}

class Form
	def initialize(template, initField)
		@form = template
		@field = initField
		@responses = {}
		@editing = false
	end

	def enter(response, event)
		if @field == 'confirm'
			if ['yes', 'y'].any? { |word| response.include?(word) }
				if @form["proc"]
					@form["submit"].call(@responses)	
				end
				# Detached itself from the user
				event.user.form = nil
				return nil
			elsif @form.has_key? response.downcase
				@editing = true
				@field = response.downcase
				return respond()
			else
				return "Invalid"
			end
		else
			@responses[@field] = response
			if @form[@field]["validator"]
				valid = @form[@field]["validator"].call(@responses)
				# puts @responnses["errorMsg"]
			else
				valid = true
			end

			if !valid
				# keep same field
			elsif @editing
				@field = "confirm"
			else
				@field = @form[@field]["next"]
			end
			return respond(valid)
		end
	end

	def respond(valid = true)
		# puts "Message: #{@responses['errorMsg']}"
		return valid ? @form[@field]["request"] : (@responses["errorMsg"] + "\n" + @form[@field]["request"])
	end
end