require 'date'
require 'bigdecimal'
require_relative 'Polo'
require_relative 'Database'

class Robot

	def initialize (key, secret, db_name)
		@database = Database.new(db_name)
		@polo = Polo.new(key, secret, @database)

		while true
			begin
				@pairs = @database.pairs
				@profile = @database.profile

				exit_when_stop

				trade

				sleep @profile['trade_timeout'].to_f
			rescue Exception => exception
				log_exception(exception) if exception.message != 'exit'

				exit_when_stop

				sleep @profile['trade_timeout'].to_f * @profile['rescue_mul'].to_f
			end
		end
	end

	private

	def trade
		@money = @polo.money
		@orders = @polo.orders
		@usdt_candle = @polo.candles('USDT').last

		@pairs.each { |pair|
			begin
				@profile = @database.profile

				exit_when_stop

				@pair = pair
				@polo.pair = pair
				@database.pair = pair

				trade_pair
			rescue Exception => exception
				log_exception(exception) if exception.message != 'exit'

				exit_when_stop
			end
		}
	end

	def trade_pair
		@candles = @polo.candles

		meta = @database.meta
		low = actualize_low(meta['low'])
		meta['low'] = low
		@database.meta = meta

		unless low
			return
		end

		if meta['calm']
			date = parse_date(meta['calm'])

			if date > DateTime.now.new_offset(0) + time_offset
				return
			end
		end

		orders = @orders["BTC_#{@pair}"]

		if orders.length == 0
			next_state(meta)
		end

		trade_by_state(meta, orders[0])
	end

	def next_state(meta)
		case meta['state']
			when 'buy'
				meta['state'] = 'hold'
				meta['sell_slice'] = DateTime.now - time_offset
				meta['unused_btc'] = 0
			when 'hold'
				meta['state'] = 'calm'
				meta['calm'] = DateTime.now + @profile['calm_days'].to_f
			when 'calm'
				if is_red_candle(@candles.last)
					meta['state'] = 'buy'
				end
			else
				# do nothing
		end

		@database.meta = meta
	end

	def trade_by_state(meta, order)
		case meta['state']
			when 'buy'
				buy(meta, order)
			when 'hold'
				hold(meta, order)
			when 'calm'
				# do nothing
			else
				# do nothing
		end
	end

	def buy(meta, order)
		rate = first_in_glass('asks')
		sell_slice = parse_date(meta['sell_slice'])

		if order
			amount = num(order['rate']) * num(order['amount']) / rate

			@polo.replace(order['orderNumber'], rate, amount)
		else
			btc = calc_btc(sell_slice, num(meta['unused_btc']))
			amount = btc / rate

			@polo.buy(rate, amount)
			meta['low'] = 0
			@database.meta = meta
			@database.log_trade('BUY', btc)
		end
	end

	def hold(meta, order)
		sigma = calc_sigma(meta)
		rate = meta['low'] * @profile['top_price'].to_f * sigma
		min = first_in_glass('bids') * @profile['min_sell_mul'].to_f

		if rate / 10 < min
			@database.log_warn("So small rate for #{@pair} (rate #{rate}, min #{min}, sigma #{sigma})")
			return
		end

		rate = min if rate < min

		if order
			amount = num(order['amount']) + num(@money[@pair])

			@polo.replace(order['orderNumber'], rate, amount)
		else
			amount = num(@money[@pair])

			@polo.sell(rate, amount)
			@database.log_trade('SELL', rate * amount)
		end
	end

	def actualize_low(meta_low = 0)
		low = calc_low
		meta_low = num(meta_low)

		if low == 0 and meta_low == 0
			return nil
		end

		if meta_low != 0 and low > meta_low
			low = meta_low
		end

		if low != meta_low
			@database.meta = {:low => low, :low_usdt => @usdt_candle['low']}
		end

		low
	end

	def calc_low
		low = num('+Infinity')

		@candles.each { |candle|
			candle_low = num(candle['low'])

			if candle_low < low
				low = candle_low
			end
		}

		num(low)
	end

	def calc_btc(sell_slice, unused)
		unless sell_slice
			return unused
		end

		sum = num(0)
		sell_slice = sell_slice - one_second

		@polo.history(sell_slice).each { |trade|
			if trade['type'] == 'sell'
				sum += num(trade['total']) * (1 - num(trade['fee']))
			end
		}

		sum + unused
	end

	def calc_sigma(meta)
		usdt_low = num(meta['usdt_low'])

		if usdt_low == 0
			return num(1)
		end

		num(@usdt_candle['low']) / usdt_low
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

	def parse_date(date)
		unless date
			return nil
		end

		DateTime.strptime(date, '%Y-%m-%d %H:%M:%S')
	end

	def num(number)
		number = (number or 0)

		BigDecimal.new(number.to_s)
	end

	def log_exception(exception)
		puts exception.message
		puts exception.backtrace.inspect

		@database.log_error("#{exception.message} --- #{exception.backtrace.inspect}")
	end

	def time_offset
		3.0 / 24
	end

	def one_second
		1 / 24.0 / 60.0 / 60.0
	end

end