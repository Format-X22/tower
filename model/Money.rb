require_relative '_'

class Model::Money < Model::Abstract

	def get
		num(@stock.money)
	end

end