require 'Date'
require 'BigDecimal'
require_relative 'Polo'
require_relative 'Database'

class Robot

	TRADE_INTERVAL = 60 * 60
	TOP_PRICE = BigDecimal.new(2.97)

	def initialize (key, secret, pairs)
		@pairs = pairs

		Database.connect
		Polo.auth(key, secret)

		while true
			begin
				trade
				sleep TRADE_INTERVAL
			rescue Exception => exception
				puts exception.message
				puts exception.backtrace.inspect
				sleep TRADE_INTERVAL * 5
			end
		end
	end

	def trade
		extract_shared_data

		@pairs.each { |pair|
			trade_pair(pair)
		}
	end

	def extract_shared_data
		@money = Polo.money
		@orders = Polo.orders

		candles = Polo.candles('USDT')
		meta = Database.meta('USDT')
		low = actualize_low('USDT', meta.low, candles)

		@usd_sigma = low / candles.last.weightedAverage
	end

	def trade_pair(pair)
		meta = Database.meta(pair)
		low = actualize_low(pair, meta.low)

		if meta.calm and meta.calm > Date.today
			return
		end

		unless @orders["BTC_#{pair}"].length
			next_state(pair, meta)
		end

		order = @orders["BTC_#{pair}"][0]

		trade_by_state(meta, low, order)
	end

	def next_state(pair, meta)
		case meta.state
			when 'buy'
				meta.state = 'hold'
			when 'hold'
				meta.state = 'calm'
				meta.calm = Date.today + 3
			when 'calm'
				meta.state = 'buy'
			else
				# do nothing
		end

		Database.meta(pair, meta)
	end

	def trade_by_state(meta, low, order)
		case meta.state
			when 'buy'
				rate = Polo.glass(pair)[0][0]
				btc = @money['BTC']
				amount = BigDecimal.new(btc) / rate

				if order
					Polo.replace(order.orderNumber, rate, amount)
				else
					Polo.buy(rate, amount)
					meta.low = nil
					Database.meta(pair, meta)
				end
			when 'hold'
				rate = low * TOP_PRICE * @usd_sigma
				amount = @money[pair]

				if order
					Polo.replace(order.orderNumber, rate, amount)
				else
					Polo.sell(rate, amount)
				end
			when 'calm'
				# do nothing
			else
				# do nothing
		end
	end

	def actualize_low(pair, meta_low, *candles)
		candles = Polo.candles(pair) unless candles
		low = calc_low(candles)

		if meta_low and low > meta_low
			low = meta_low
		end

		if low != meta_low
			Database.meta(pair, {:low => low})
		end

		BigDecimal.new(low)
	end

	def calc_low (candles)
		low = Infinity

		candles.each { |candle|
			if candle.low < low
				low = candle.low
			end
		}

		low
	end

end