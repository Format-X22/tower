require_relative '_'

class Algorithm::Abstract

	def initialize
		@utils = Util::Misc.new
	end

	def now
		@utils.now
	end

end