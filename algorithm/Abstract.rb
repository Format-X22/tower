require_relative '../model/Utils'

class Abstract

	def initialize
		@utils = Utils.new
	end

	def now
		@utils.now
	end

end