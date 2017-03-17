require_relative '_'

class Algorithm_Pair_Executor < Algorithm_Abstract

	def initialize(context)
		super()
		@candles = Model_Candles.new(context)
		@glass   = Model_Glass.new(context)
		@profile = Model_Profile.new(context)
		@meta    = Model_Meta.new(context)
		@order   = Model_Order.new(context)
		@money   = Model_Money.new(context)
		@trader  = Model_Trader.new(context)
	end

	def tick
		@candles.sync
		@candles.last_candle
	end

	def low_tick
		@candles.sync
		@candles.low_from(now - profile.low_reset_time)
	end

	def glass
		@glass
	end

	def profile
		@profile
	end

	def meta
		@meta
	end

	def order
		@order.list.first
	end

	def money
		@money.money
	end

	def buy_order(rate, amount)
		@trader.buy(rate, amount)
	end

	def sell_order(rate, amount)
		@trader.sell(rate, amount)
	end

	def replace_order(id, rate, amount)
		@trader.replace(id, rate, amount)
	end

	def history(from) # TODO Model
		# TODO
	end

end