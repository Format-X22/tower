require 'date'
require 'bigdecimal'
require_relative 'Polo'
require_relative 'Database'

class Robot

	TRADE_TIMEOUT = 60 * 60
	TOP_PRICE = BigDecimal.new('1.97')

	def initialize (key, secret, db_name)
		@polo = Polo.new(key, secret)
		@database = Database.new(db_name)
		@pairs = @database.pairs

		while true
			trade
			sleep TRADE_TIMEOUT
		end
	end

	def trade
		@money = @polo.money
		@orders = @polo.orders
		@usdt_candle = @polo.candles('USDT').last

		@pairs.each { |pair|
			trade_pair(pair)
		}
	end

	def trade_pair(pair)
		meta = @database.meta(pair)
		low = actualize_low(pair, meta['low'])

		if meta['calm']
			date = DateTime.strptime(meta['calm'], '%Y-%m-%d %H:%M:%S')

			if date > DateTime.now
				return
			end
		end

		return

		unless @orders["BTC_#{pair}"].length
			next_state(pair, meta)
		end

		order = @orders["BTC_#{pair}"][0]

		trade_by_state(meta, low, order)
	end

	def next_state(pair, meta)
		case meta['state']
			when 'buy'
				meta['state'] = 'hold'
				meta['sell_slice'] = DateTime.now
			when 'hold'
				meta['state'] = 'calm'
				meta['calm'] = Date.today + 3
			when 'calm'
				meta['state'] = 'buy'
			else
				# do nothing
		end

		@database.meta(pair, meta)
	end

	def trade_by_state(meta, low, order)
		case meta['state']
			when 'buy'
				rate = @polo.glass(pair)[0][0]
				btc = @money['BTC']
				amount = BigDecimal.new(btc.to_s) / rate

				if order
					@polo.replace(order.orderNumber, rate, amount)
				else
					@polo.buy(pair, rate, amount)
					meta['low'] = nil
					@database.meta(pair, meta)
				end
			when 'hold'
				rate = low * TOP_PRICE * @usd_sigma
				amount = @money[pair]

				if order
					@polo.replace(order.orderNumber, rate, amount)
				else
					@polo.sell(pair, rate, amount)
				end
			when 'calm'
				# do nothing
			else
				# do nothing
		end
	end

	def actualize_low(pair, meta_low = 0, candles = nil)
		candles = @polo.candles(pair) unless candles
		low = calc_low(candles)
		meta_low = BigDecimal.new(meta_low.to_s)

		if meta_low != 0 and low > meta_low
			low = meta_low
		end

		if low != meta_low
			@database.meta(pair, {:low => low, :low_usdt => @usdt_candle['low']})
		end

		low
	end

	def calc_low (candles)
		low = BigDecimal.new('+Infinity')

		candles.each { |candle|
			candle_low = BigDecimal.new(candle['low'].to_s)

			if candle_low < low
				low = candle_low
			end
		}

		BigDecimal.new(low.to_s)
	end

end