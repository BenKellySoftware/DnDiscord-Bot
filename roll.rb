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