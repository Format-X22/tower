require_relative '_'

class Algorithm::Abstract

	def initialize
		@utils = Model::Utils.new
	end

	def now
		@utils.now
	end

end