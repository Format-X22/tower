require_relative '_'

class Algorithm::Pair::Executor < Algorithm::Abstract

	def initialize(context)
		super()
		@candles = Model::Candles.new(context)
		@glass   = Model::Glass.new(context)
		@profile = Model::Profile.new(context)
		@meta    = Model::Meta.new(context)
		@order   = Model::Order.new(context)
		@money   = Model::Money.new(context)
		@trader  = Model::Trader.new(context)
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
		@glass.get
	end

	def profile
		@profile.get
	end

	def meta
		@meta.get
	end

	def order
		@order.get.first
	end

	def money
		@money.get
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

end