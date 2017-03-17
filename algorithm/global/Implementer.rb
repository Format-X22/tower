require_relative '_'

class Algorithm_Global_Implementer < Algorithm_Global_Executor

	def stop?
		config.stop
	end

	def each_stock(&block)
		safe_call do
			config.stocks.each do |stock|
				context.stock = stock
				block.call
			end
		end
	end

	def stock_trade(&block)
		safe_call do
			Algorithm_Stock_Specification
				.new(context)
				.run &block
		end
	end

	def each_profile(&block)
		config.profiles.each do |profile|
			context.profile = profile
			block.call
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
			Algorithm_Pair_Specification
				.new(context)
				.run
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