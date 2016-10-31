require_relative 'base_stats'

class Player
	def initialize(name, role, race, alignment)
		@name = name;
		@class = role;
		@race = race;
		@alignment = alignment;
		@level = 1;
		@abilities = {
			"Str" => 13,
			"Dex" => 15,
			"Con" => 13,
			"Int" => 10,
			"Wis" => 8,
			"Cha" => 17
		}
		@proficiencies = ["Str", "Dex", "Deception", "Performance", "Slight of Hand"]
	end

	def savingThrow(abilityName, difficulty, advantage = "", extra = 0)
		modifier = savingThrowModifier(abilityName) + extra
		
		if advantage == "advantage"
			roll = rollDouble(true)
		elsif advantage == "disadvantage"
			roll = rollDouble(false)
		else
			roll = roll(20)
		end
		print "With a #{modifier > 0 ? "+": ""}#{modifier} modifier, "
		if (roll + modifier >= difficulty || roll == 20) && roll != 1
			print "you Successed "
		else
			print "you Failed "
		end
		puts "with a total score of #{roll + modifier}" 
	end

	#Stat Getters
	def proficiencyBonus
		(@level+7)/4
	end

	def abilityModifier (abilityStat)
		(abilityStat-10)/2
	end

	def isProficient? (statName) 
		@proficiencies.include? statName
	end

	def skillModifier(skill)
		return @proficiencies.include? skill
	end

	def savingThrowModifier(abilityName)
		abilityModifier(@abilities[abilityName[0..2]]) + (isProficient?(abilityName) ? proficiencyBonus() : 0)
	end

	def raceStats
		Races.find {|race| race["name"] == @race}	
	end

	def speed
		raceStats()["speed"]
	end
end