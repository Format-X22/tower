require_relative '_'

class Algorithm::Global::Implementer < Algorithm::Global::Executor

	def stop?
		config.stop
	end

	def each_stock(&body)
		#
	end

	def stock_trade
		#
	end

	def each_pair(&body)
		#
	end

	def pair_trade
		#
	end

end