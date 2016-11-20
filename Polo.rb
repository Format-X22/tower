require 'date'
require 'uri'
require 'openssl'
require 'net/http'
require 'json'

class Polo
	CANDLES_MARGIN = 2 * 60 * 60
	CANDLES_END = 9999999999
	CANDLES_PERIOD = 300

	def initialize(key, secret)
		@key = key
		@secret = secret
	end

	def candles(pair)
		if pair == 'USDT'
			currency_pair = 'USDT_BTC'
		else
			currency_pair = "BTC_#{pair}"
		end

		public_api_call({
			:command => 'returnChartData',
			:currencyPair => currency_pair,
			:start => margin(CANDLES_MARGIN),
			:end => CANDLES_END,
			:period => CANDLES_PERIOD
						})
	end

	def glass(pair)
		public_api_call({
			:command => 'returnOrderBook',
			:currencyPair => "BTC_#{pair}",
			:depth => 100
						})
	end

	def money
		private_api_call({
			:command => 'returnAvailableAccountBalances',
			:account => 'exchange'
						 })['exchange']
	end

	def orders
		private_api_call({
			:command => 'returnOpenOrders',
			:currencyPair => 'all'
						 })
	end

	def history(pair, from)
		private_api_call({
			:command => 'returnTradeHistory',
			:currencyPair => "BTC_#{pair}",
			:start => from.to_i,
						 })
	end

	def buy(pair, rate, amount)
		trade('buy', pair, rate, amount)
	end

	def sell(pair, rate, amount)
		trade('sell', pair, rate, amount)
	end

	def replace(id, rate, amount)
		private_api_call({
			:command => 'moveOrder',
			:orderNumber => id,
			:rate => rate,
			:amount => amount
						 })
	end

	private

	def trade(type, pair, rate, amount)
		private_api_call({
			:command => type,
			:currencyPair => "BTC_#{pair}",
			:rate => rate,
			:amount => amount
						 })
	end

	def public_api_call(config)
		params = URI.encode_www_form(config)
		response = Net::HTTP.get(URI("https://poloniex.com/public?#{params}"))

		JSON.parse(response)
	end

	def private_api_call(config)
		config[:nonce] = Time.now.to_i

		uri = URI('https://poloniex.com/tradingApi')
		headers = request_headers(config)
		request = Net::HTTP::Post.new(uri, headers)
		request.set_form_data(config)
		result = nil

		Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) do |http|
			result = JSON.parse(http.request(request).body)
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

	def margin(timestamp)
		(Time.now - timestamp).to_i
	end
end