class Executor

	def initialize(pair:)
		@pair = pair
	end

	def tick
		#
	end

	def low_tick
		#
	end

	def glass
		#
	end

	def profile
		#
	end

	def meta
		#
	end

	def order
		#
	end

	def money
		#
	end

	def stop_trade
		#
	end

	def buy_order(rate, amount)
		#

		log_trade('BUY', rate * amount)
	end

	def sell_order(rate, amount)
		#

		log_trade('SELL', rate * amount)
	end

	def replace_order(id, rate, amount)
		#
	end

	def now
		DateTime.now.new_offset(0)
	end

end