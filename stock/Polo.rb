require_relative '_'
require 'date'
require 'uri'
require 'openssl'
require 'net/http'
require 'json'

class Polo
	attr_reader :twitter_name
	attr_writer :pair

	def initialize(key, secret, pair = nil)
		@twitter_name = 'poloniex'

		@key = key
		@secret = secret
		@pair = pair
	end

	def candles(from, to = 9999999999)
		if @pair == 'USDT'
			currency_pair = usdt_pair
		else
			currency_pair = btc_pair
		end

		public_api_call(
			command: 'returnChartData',
			currencyPair: currency_pair,
			start: date_to_i(from),
			end: date_to_i(to),
			period: 300
		)
	end

	def glass(depth = 100)
		public_api_call(
			command: 'returnOrderBook',
			currencyPair: btc_pair,
			depth: depth
		)
	end

	def money
		private_api_call(
			command: 'returnAvailableAccountBalances',
		)['exchange']
	end

	def orders
		private_api_call(
			command: 'returnOpenOrders',
			currencyPair: 'all'
		)
	end

	def history(from)
		private_api_call(
			command: 'returnTradeHistory',
			currencyPair: btc_pair,
			start: date_to_i(from),
		)
	end

	def buy(rate, amount)
		trade('buy', rate, amount)
	end

	def sell(rate, amount)
		trade('sell', rate, amount)
	end

	def replace(id, rate, amount)
		private_api_call(
			command: 'moveOrder',
			orderNumber: id,
			rate: readable_num(rate),
			amount: readable_num(amount)
		)
	end

	private

	def trade(type, rate, amount)
		private_api_call(
			command: type,
			currencyPair: btc_pair,
			rate: readable_num(rate),
			amount: readable_num(amount)
		)
	end

	def public_api_call(config)
		params = URI.encode_www_form(config)
		uri = URI("https://poloniex.com/public?#{params}")
		response = Net::HTTP.get(uri)
		result = JSON.parse(response)

		unless result.is_a?(Hash)
			raise 'Public api call result is not a hash'
		end

		if result['error']
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

		Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
			result = JSON.parse(http.request(request).body)
		end

		unless result.is_a?(Hash)
			raise 'Private api call result is not a hash'
		end

		if result['error']
			raise "#{result['error']} - #{config}"
		end

		result
	end

	def request_headers(body)
		params = URI.encode_www_form(body)
		digest = OpenSSL::Digest.new('sha512')
		sign   = OpenSSL::HMAC.hexdigest(digest, @secret, params)

		{
			'Key': @key,
			'Sign': sign,
			'Content-Type': 'application/json'
		}
	end

	def btc_pair
		"BTC_#{@pair}"
	end

	def usdt_pair
		'USDT_BTC'
	end

end