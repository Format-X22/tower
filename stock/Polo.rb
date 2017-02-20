require 'date'
require 'uri'
require 'openssl'
require 'net/http'
require 'json'

require_relative './Abstract'
require_relative '../util/Format'

class Polo < Abstract

	def candles(from, to, pair = @pair)
		to = 9999999999 unless to

		if pair == 'USDT'
			currency_pair = 'USDT_BTC'
		else
			currency_pair = "BTC_#{pair}"
		end

		public_api_call(
			command: 'returnChartData',
			currencyPair: currency_pair,
			start: Format.date_to_i(from),
			end: Format.date_to_i(to),
			period: 300
		)
	end

	def glass(depth = 100)
		public_api_call(
			command: 'returnOrderBook',
			currencyPair: "BTC_#{@pair}",
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
			currencyPair: "BTC_#{@pair}",
			start: Format.date_to_i(from),
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
			rate: Format.readable_num(rate),
			amount: Format.readable_num(amount)
		)
	end

	private

	def trade(type, rate, amount)
		private_api_call(
			command: type,
			currencyPair: "BTC_#{@pair}",
			rate: Format.readable_num(rate),
			amount: Format.readable_num(amount)
		)
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

		Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
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
			'Key' => @key,
			'Sign' => OpenSSL::HMAC.hexdigest(digest, @secret, params),
			'Content-Type' => 'application/json'
		}
	end

end