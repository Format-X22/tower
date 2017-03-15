require_relative '_'

class Model_Money < Model_Abstract

	def get
		num(@stock.money)
	end

end