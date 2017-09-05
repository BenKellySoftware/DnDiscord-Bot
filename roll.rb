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