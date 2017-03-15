require_relative '_'

class Algorithm::Global::Executor < Algorithm::Abstract

	def initialize
		super
	end

	def config
		@config.get
	end

end