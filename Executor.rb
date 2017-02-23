require 'big_decimal'

class Executor

	def initialize(db:, polo:)
		@db = db
		@polo = polo
	end

	def tick
		old_candle = @db.last_candle
		candles = @polo.candles(old_candle.date)

		if candles
			@db.merge_candles(candles)
			@db.last_candle
		else
			old_candle
		end
	end

	def low_tick
		#
	end

	def glass
		@polo.glass
	end

	def profile
		profile_data = @db.profile

		#
	end

	def meta
		meta_data = @db.meta

		#
	end

	def order
		orders_data = @polo.orders

		#
	end

	def money
		num(@polo.money)
	end

	def stop_trade
		@db.stop_trade
	end

	def buy_order(rate, amount)
		@polo.buy(rate, amount)

		log_trade('BUY', rate * amount)
	end

	def sell_order(rate, amount)
		@polo.sell(rate, amount)

		log_trade('SELL', rate * amount)
	end

	def replace_order(id, rate, amount)
		@polo.replace(id, rate, amount)
	end

	def now
		DateTime.now.new_offset(0)
	end

	def num(number)
		BigDecimal.new(number.to_s)
	end

end