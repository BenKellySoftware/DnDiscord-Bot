require_relative 'base_stats'

class Player
	attr_reader :name, :race, :class, :level
	def initialize(name, race, role)
		@name = name;
		@class = role;
		@race = race;
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
		message = "With a #{modifier > 0 ? "+": ""}#{modifier} modifier, "
		if (roll + modifier >= difficulty || roll == 20) && roll != 1
			message += "you successed"
		else
			message += "you failed"
		end
		return "#{message} with a total score of #{roll + modifier}" 
	end

	def maxHealth
		#Replace with class hitdie, just d8 for now
		hitdie = 8
		return ((@level-1)*((hitdie/2)+1))+hitdie
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