require_relative '_'

class Model_Money < Model_Abstract
	attr_reader :money

	def initialize(context)
		super

		@money = @stock.money
	end

end