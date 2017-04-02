require 'pg'
require 'date'
require 'uri'
require 'openssl'
require 'net/http'
require 'json'
require 'bigdecimal'
require 'twitter'

class Robot

	def initialize
		@connection = PG.connect(dbname: 'tower-b')
		@key = 'VFYTOUL8-QMXD4PCQ-LDEMD2GG-MJD9IXY3'
		@secret = '9f7d888231869a591a414a691ec43a9eb02479016b610da7903edc8d656ac713a0beb163645ae963cb2430d476524572a941d33b200b666dae470cf52e8ce22e'

		@polo = Polo.new(@database)

		guard = Guard.new(@database, @polo)

		while true
			begin
				@pairs = @database.pairs

				exit_when_stop

				if guard.check_de_listing == 'ok'
					trade
				end
			rescue Exception => exception
				exit_when_stop

				sleep 5000
			end
		end
	end

	private

	def trade
		@money = @polo.money
		@orders = @polo.orders

		@pairs.each do |pair|
			begin
				@profile = @database.profile

				exit_when_stop

				@pair = pair
				@polo.pair = pair
				@database.pair = pair

				trade_pair
			rescue Exception => exception
				exit_when_stop
			end
		end
	end

	def trade_pair
		if price > target
			sell
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

		@candles.each do |candle|
			candle_low = num(candle['low'])

			if candle_low < low
				low = candle_low
			end
		end

		num(low)
	end

	def calc_btc(sell_slice, unused)
		unless sell_slice
			return unused
		end

		sum = num(0)
		sell_slice = sell_slice - one_second

		@polo.history(sell_slice).each do |trade|
			if trade['type'] == 'sell'
				sum += num(trade['total']) * (1 - num(trade['fee']))
			end
		end

		sum + unused
	end

	def calc_sigma(meta)
		usdt_low = num(meta['usdt_low'])

		if usdt_low == 0
			return num(1)
		end

		num(@usdt_candle['low']) / usdt_low
	end

	def pair=(pair)
		@pair = pair
	end

	def profile
		result = nil

		exec('SELECT * FROM profile').each do |row|
			result = row
		end

		if result['stop'] == 't'
			result['stop'] = true
		else
			result['stop'] = false
		end

		result
	end

	def meta
		result = nil

		exec('SELECT * FROM meta WHERE pair = $1', [@pair]).each do |row|
			result = row
		end

		result
	end

	def meta=(values)
		data = []

		values.each do |key, value|
			data.push("#{key}='#{value}'") if value
		end

		if data.length == 0
			log_error('Try save empty meta')
			return
		end

		query = data.join(', ')
		exec("UPDATE meta SET #{query} WHERE pair = $1", [@pair])
	end

	def pairs
		result = []

		exec('SELECT pair FROM pairs WHERE trade = TRUE').values.each do |row|
			result.push(row[0])
		end

		result
	end

	def log(text)
		p text

		exec('INSERT INTO log_text (text) VALUES ($1)', [text])
	end

	def log_error(text)
		p text

		exec('INSERT INTO log_text (type, text) VALUES ($1, $2)', ['ERROR', text])
	end

	def log_trade(type, btc)
		p "#{type} - #{btc}"

		exec('INSERT INTO log_trade (type, pair, btc) VALUES ($1, $2, $3)', [type, @pair, btc])
	end

	def stop_pair_trade
		exec('UPDATE pairs SET trade = FALSE WHERE pair = $1', [@pair])
	end

	private

	def exec(query, *params)
		if params.length > 0
			@connection.exec_params(query, *params)
		else
			@connection.exec(query)
		end
	end

	def pair=(pair)
		@pair = pair
	end

	def money
		private_api_call({
							 :command => 'returnAvailableAccountBalances',
						 })['exchange']
	end

	def orders
		private_api_call({
							 :command => 'returnOpenOrders',
							 :currencyPair => 'all'
						 })
	end

	def sell(rate, amount)
		trade('sell', rate, amount)
	end

	def replace(id, rate, amount)
		private_api_call({
							 :command => 'moveOrder',
							 :orderNumber => id,
							 :rate => readable(rate),
							 :amount => readable(amount)
						 })
	end

	def readable(num)
		'%1.8f' % num.to_f
	end

	private

	def trade(type, rate, amount)
		private_api_call({
							 :command => type,
							 :currencyPair => "BTC_#{@pair}",
							 :rate => readable(rate),
							 :amount => readable(amount)
						 })
	end

	def public_api_call(config)
		params = URI.encode_www_form(config)
		response = Net::HTTP.get(URI("https://poloniex.com/public?#{params}"))
		result = JSON.parse(response)

		if result.is_a?(Hash) and result['error']
			raise "#{result['error']} - #{config}"
		end

		result
	end

	def private_api_call(config)
		config[:nonce] = (Time.now.to_f * 1000).to_i

		uri = URI('https://poloniex.com/tradingApi')
		headers = request_headers(config)
		request = Net::HTTP::Post.new(uri, headers)
		request.set_form_data(config)
		result = nil

		Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) do |http|
			result = JSON.parse(http.request(request).body)
		end

		if result.is_a?(Hash) and result['error']
			raise "#{result['error']} - #{config}"
		end

		result
	end

	def request_headers(body)
		params = URI.encode_www_form(body)

		digest = OpenSSL::Digest.new('sha512')

		{
			'Key': @key,
			'Sign': OpenSSL::HMAC.hexdigest(digest, @secret, params),
			'Content-Type': 'application/json'
		}
	end

	def margin(timestamp)
		(Time.now - timestamp).to_i
	end

	def pair_orders(pair, all_orders)
		all_orders["BTC_#{pair}"]
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

	def log_exception(exception, message_prefix = '')
		message = "#{message_prefix}#{exception.message}"

		p message

		if @database
			@database.log_error("#{message} --- #{exception.backtrace.inspect}")
		end
	end

	def time_offset
		3.0 / 24
	end

	def initialize(database, polo)
		@database = database
		@polo = polo
		@twitter = Twitter::REST::Client.new do |config|
			config.consumer_key        = 'Ttq7dDhLdXbXBrfvDz6DwSL36'
			config.consumer_secret     = 'nQ6G5RV1vOtsDZq0es2sqvbaHKE3IwiTwbz8u54cg2zpbiC3mY'
			config.access_token        = '813051612423946240-yxaKsK2py0Za8whvAfyQUIRaS6fIXhV'
			config.access_token_secret = 'jeAGtOnRAndK3BQaPrkM1EFoRPxmq7mG1l29xeTNkiPgC'
		end
	end

	def check_de_listing
		pairs = @database.pairs
		money = @polo.money
		status = 'ok'

		@twitter.user_timeline('poloniex').each do |tweet|
			if tweet.text.match('delist')
				de_listed = parse_de_listing_pairs(tweet.text, pairs, money)

				if de_listed.length > 0
					panic_sell(de_listed, money)
					status = 'de_listing'
				end
			end
		end

		status
	end

	private

	def parse_de_listing_pairs(text, pairs, money)
		de_listed = []
		all_orders = @polo.orders

		pairs.each do |pair|
			if /\s#{pair}|,#{pair}|:#{pair}/.match(text)
				if num(money[pair]) > 0 or pair_orders(pair, all_orders).length > 0
					de_listed.push(pair)
				else
					@database.stop_pair_trade
				end
			end
		end

		de_listed
	end

	def panic_sell(pairs, money)
		all_orders = @polo.orders

		pairs.each do |pair|
			begin
				panic_sell_for(
					pair,
					num(money[pair]),
					pair_orders(pair, all_orders)
				)
			rescue Exception => exception
				log_exception(exception, 'Panic sell error - ')
			end
		end
	end

	def panic_sell_for(pair, pair_money, orders)
		@polo.pair = pair
		@database.pair = pair

		if orders.length > 0
			orders.each do |order|
				rate = first_in_glass('bids')
				amount = num(order['amount'])

				begin
					@polo.replace(order['orderNumber'], rate, amount)
				rescue Exception => exception
					log_exception(exception, 'Panic sell error - ')
				end
			end
		else
			make_panic_sell_train(pair_money).each do |wagon|
				@polo.sell(wagon[0], wagon[1])
			end

			@database.log_trade('PANIC SELL', 0)
		end
	end

	def make_panic_sell_train(total_amount)
		glass = @polo.glass['bids']
		train = []
		glass.shift

		while total_amount > 0
			order = glass.shift
			rate = num(order[0])
			amount = num(order[1])

			if amount > total_amount
				train.push([rate, total_amount])
			else
				train.push([rate, amount])
			end

			total_amount -= amount
		end

		train
	end

end