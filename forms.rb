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
				if Client["characters"].find({"name" => responses["name"]}).count() > 0
					responses["errorMsg"] = "A character with that name exists"
					false
				else
					true
				end
			end
		},
		"race" => {
			"request" => "Race: \nType full race name, including subrace (e.g. High-Elf, Forest Gnome, Duergar etc.) \nType 'list' for a list of the races (TODO).",
			"next" => "class",
			"validate" => lambda do |responses|
				if responses["race"].downcase.eql? "list"
					responses["errorMsg"] = "TODO: List races"
					false
				else
					race = Client["races"].find({"name" => responses["race"]}).limit(1).first()
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
		"class" => {
			"request" => "Class you want to take your first level in:",
			"next" =>	"abilities",
			"validate" => lambda do |responses|
				if responses["class"].downcase.eql? "list"
					responses["errorMsg"] = "TODO: List class"
					false
				else
					classObj = Client["classes"].find({"name" => responses["class"].capitalize}).limit(1).first()
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
		"abilities" => {
			"request" => "Ability Scores (raw numbers, pre-modifiers), write 6 numbers, comma seperated, between 1 and 20 in the order str,dex,con,int,wis,cha:",
			"next" => "background",
			"validate" => lambda do |responses|
					abilityArr = responses['abilities'].split(',').map(&:to_i)
					if abilityArr.length != 6
						responses["errorMsg"] = "Not the right number of ability scores"
						false
					elsif abilityArr.any? { |ability| ability > 20 or ability < 1}
						responses["errorMsg"] = "Not all scores are within valid range (1-20)"
						false
					else
						responses["abilityArr"] = abilityArr
						true
					end
			end
		},
		"background" => {
			"request" => "Your characters background:",
			"next" => "skills"
		},
		"skills" => {
			"request" =>"Your starting skill proficiencies (4 by default, 5 for Bard and Ranger, 6 for Rogue), comma seperated.\nNote, these do not include any race or first level proficiency bonuses (they'll be applied later):",
			"next" => "confirm",
			"validate" => lambda do |responses|
				skillArr = responses['skills'].split(',').map{|skill| skill.strip.titleize}
				# Add 2 to the list for background
				# TODO: Limit skills by class/ background restriction
				count = responses['classObj']['skillCount'] + 2
				if skillArr.length != count
					responses["errorMsg"] = "Not the right number of skills"
					false
				elsif skillArr.any? { |skill| !Skills.include? skill}
					responses["errorMsg"] = "Not all valid skill names"
					false
				else
					responses["skillArr"] = skillArr
					true
				end
			end
		},
		"confirm" => {
			"request" => "Type yes to move on and apply features, or a field name to edit:",
			"submit" => lambda do |responses, event|
				characterJSON = {
					'name' => responses['name'],
					'fullName' => responses['fullName'],
					'race' => responses['race'],
					'levels' => [{
						'name' => responses['class'],
						'level' => 0
					}],
					'speed' => responses['raceObj']['speed'],
					'maxHitpoints' => responses['classObj']['hitdice'] + (responses['abilityArr'][2] + (responses['raceObj']['abilities']['con'] || 0) - 10)/2,
					'background' => responses['background'],
					'abilities' => {
						'str' => responses['abilityArr'][0] + (responses['raceObj']['abilities']['str'] || 0),
						'dex' => responses['abilityArr'][1] + (responses['raceObj']['abilities']['dex'] || 0),
						'con' => responses['abilityArr'][2] + (responses['raceObj']['abilities']['con'] || 0),
						'int' => responses['abilityArr'][3] + (responses['raceObj']['abilities']['int'] || 0),
						'wis' => responses['abilityArr'][4] + (responses['raceObj']['abilities']['wis'] || 0),
						'cha' => responses['abilityArr'][5] + (responses['raceObj']['abilities']['cha'] || 0)
					},
					'skills' => responses['skillArr'],
					'saves' => responses['classObj']['savingThrows'],
					'languages' => responses['raceObj']['languages'],
					'features' => []
				}

				# TODO: Apply weapon/ armour/ tool proficiencies

				# Apply race features
				characterJSON['features'].concat(responses['raceObj']['features'])
				character = Character.new(characterJSON, event.user)
				# Initial Level up
				character.levelUp(responses['class'])

				# Client['characters'].insert_one characterJSON
				character.upload

				event.user.character = character
				$party.push(character)
				return "Welcome to the party #{character.fullName}"
			end
		}
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
				# Detached itself from the user
				@user.form = nil
				if @form['confirm']["submit"]
					return @form['confirm']["submit"].call(@responses, event)	
				end
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
				begin
					valid = @form[@field]["validate"].call(@responses)
				rescue Exception => e
					puts e.message
					valid = false
					@responses['errorMsg'] = "An unknown error occured"
				end
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