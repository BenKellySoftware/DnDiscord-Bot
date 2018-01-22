Forms = {
	"create character" => {
		"fullName" => {
			"request" => "Full name:",
			"next" => "name"
		},
		"name" => {
			"request" => "The shorthand name I'll refer to you as:",
			"next" => "race",
			"validate" => lambda do |responses|
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
			"validate" => lambda do |responses|
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
			"validate" => lambda do |responses|
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
			"validate" => lambda do |responses|
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
			"next" => "skills"
		},
		"skills" => {
			"request" => "Your skill proficiencies, comma seperated:",
			"next" => "confirm"
		},
		"confirm" => {
			"request" => "Type yes to move on and apply features, or a field name to edit:"
		},
		"submit" => lambda do |responses|
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
					"str" => responses['abilityArr'][0] + (raceObj['abilities']['str'] || 0),
					"dex" => responses['abilityArr'][1] + (raceObj['abilities']['dex'] || 0),
					"con" => responses['abilityArr'][2] + (raceObj['abilities']['con'] || 0),
					"int" => responses['abilityArr'][3] + (raceObj['abilities']['int'] || 0),
					"wis" => responses['abilityArr'][4] + (raceObj['abilities']['wis'] || 0),
					"cha" => responses['abilityArr'][5] + (raceObj['abilities']['cha'] || 0)
				},
				"features" => []
			}

			# Apply weapon/ armour/ tool proficiencies

			# Apply race features
			characterJSON['features'].push(responses['raceObj'])
			character = Character.new(characterJSON)
			# Initial Level up
			character.levelUp(responses['class'])

			$client['characters'].insert_one characterJSON
		end
	}
}

class Form
	def initialize(template, initField, user)
		@form = template
		@field = initField
		@responses = {}
		@editing = false
		@user = user
	end

	def enter(response, event)
		if @field == 'confirm'
			if ['yes', 'y'].any? { |word| response.include?(word) }
				if @form["proc"]
					@form["submit"].call(@responses)	
				end
				# Detached itself from the user
				@user.form = nil
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
			if @form[@field]["validate"]
				valid = @form[@field]["validate"].call(@responses)
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