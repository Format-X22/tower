require 'date'
require 'uri'
require 'openssl'
require 'net/http'
require 'json'
require 'bigdecimal'
require 'twitter'

class Robot

	def initialize
		while true
			begin
				trade
			rescue Exception => exception
				p exception.message

				sleep 5000
			end
		end
	end

	def trade
		connect_to_twitter

		check_delisting do
			trade_pair
		end
	end

	def trade_pair
		pairs.each do |pair|
			@pair = pair
			money = self.money

			if money and (rate >= target)
				sell
			end
		end
	end

	def connect_to_twitter
		@twitter = Twitter::REST::Client.new do |config|
			config.consumer_key        = 'Ttq7dDhLdXbXBrfvDz6DwSL36'
			config.consumer_secret     = 'nQ6G5RV1vOtsDZq0es2sqvbaHKE3IwiTwbz8u54cg2zpbiC3mY'
			config.access_token        = '813051612423946240-yxaKsK2py0Za8whvAfyQUIRaS6fIXhV'
			config.access_token_secret = 'jeAGtOnRAndK3BQaPrkM1EFoRPxmq7mG1l29xeTNkiPgC'
		end
	end

	def rate
		ticker["BTC_#{@pair}"]['last']
	end

	def target
		PAIRS[@pair]
	end

	def money
		private_api_call({
							 command: 'returnAvailableAccountBalances'
						 })['exchange']
	end

	def sell
		private_api_call({
			command:      'sell',
			currencyPair: "BTC_#{@pair}",
			rate:         readable(0.00000001),
			amount:       readable(money)
			})
	end

	def ticker
		public_api_call({
			command: 'returnTicker'
		})
	end

	def pairs
		PAIRS.map do |key, value|
			key.to.s
		end
	end

	def readable(num)
		'%1.8f' % num.to_f
	end

	def public_api_call(config)
		params = URI.encode_www_form(config)
		response = Net::HTTP.get(URI("https://poloniex.com/public?#{params}"))
		result = JSON.parse(response)

		unless result
			raise "Empty response #{config}"
		end

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

		unless result
			raise "Empty response #{config}"
		end

		if result.is_a?(Hash) and result['error']
			raise "#{result['error']} - #{config}"
		end

		result
	end

	def request_headers(body)
		params = URI.encode_www_form(body)
		digest = OpenSSL::Digest.new('sha512')
		secret = '9f7d888231869a591a414a691ec43a9eb02479016b610da7903edc8d656ac713a0beb163645ae963cb2430d476524572a941d33b200b666dae470cf52e8ce22e'

		{
			'Key': 'VFYTOUL8-QMXD4PCQ-LDEMD2GG-MJD9IXY3',
			'Sign': OpenSSL::HMAC.hexdigest(digest, secret, params),
			'Content-Type': 'application/json'
		}
	end
	








	def pair_orders(pair, all_orders)
		all_orders["BTC_#{pair}"]
	end

	def num(number)
		number = (number or 0)

		BigDecimal.new(number.to_s)
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
				@pair = pair
				sell
			rescue Exception => exception
				p "#{exception.message} --- #{exception.backtrace.inspect}"
			end
		end
	end

end