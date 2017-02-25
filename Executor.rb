require 'big_decimal'
require_relative 'model/Candles'
require_relative 'model/Glass'
require_relative 'model/Profile'
require_relative 'model/Meta'
require_relative 'model/Order'
require_relative 'model/Money'
require_relative 'model/Trader'
require_relative 'model/Utils'

class Executor

	def initialize(context)
		@candles = Candles.new(context)
		@glass = Glass.new(context)
		@profile = Profile.new(context)
		@meta = Meta.new(context)
		@order = Order.new(context)
		@money = Money.new(context)
		@trader = Trader.new(context)
		@utils = UtilsMixed.new
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
		@order.get
	end

	def money
		@money.get
	end

	def stop_trade
		@trader.stop_trade
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

	def now
		@utils.now
	end

end