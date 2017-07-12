module AsyncForms
  attr_accessor :form
end

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
			$players[responses["name"].split(" ").first] = Player.new(responses["name"], responses["race"], responses["class"])
		end
	}
}

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
				# Detached itself from the user
				event.user.form = nil
				return nil
			elsif @form.has_key? response.downcase
				@field = response.downcase	
				return respond() 	 
			else
				return "Invalid"
			end
		else
			@responses[@field] = response
			@field = @form[@field]["next"]
			return respond()
		end
	end

	def respond()
		return @form[@field]["request"]
	end
end
