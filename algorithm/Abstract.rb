require_relative '_'

class Algorithm_Abstract

	def initialize
		@utils = Util_Misc.new
	end

	def now
		@utils.now
	end

end