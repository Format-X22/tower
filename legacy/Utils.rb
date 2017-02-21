require 'date'
require 'bigdecimal'

module Utils

	def pair_orders(pair, all_orders)
		all_orders["BTC_#{pair}"]
	end

	def is_red_candle(candle)
		candle['open'] > candle['close']
	end

	def first_in_glass(type)
		num(@polo.glass[type].first.first)
	end

	def exit_when_stop
		exit if @profile['stop']
	end

	def time_offset
		3.0 / 24
	end

	def one_second
		1.0 / 24.0 / 60.0 / 60.0
	end

end