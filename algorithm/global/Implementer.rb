require_relative '_'

class Algorithm::Global::Implementer < Algorithm::Global::Executor

	def stop?
		config.stop
	end

	def each_stock(&block)
		config.stocks.each do |stock|
			context.stock = stock
			block.call
		end
	end

	def stock_trade
		safe_call do
			#
		end
	end

	def each_pair(&block)
		pairs.traded.each do |pair|
			context.pair = pair
			block.call
		end
	end

	def pair_trade
		safe_call do
			#
		end
	end

	private

	def safe_call(&block)
		begin
			block.call
		rescue Exception => exception
			if exception.message != 'exit'
				log_error(exception)
			end

			if stop?
				log('STOP')
				exit
			end

			sleep config.rescue_sleep
		end
	end

end