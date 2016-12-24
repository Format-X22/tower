require 'date'
require 'uri'
require 'openssl'
require 'net/http'
require 'json'

class Polo
	CANDLES_MARGIN = 3 * 60 * 60
	CANDLES_END = 9999999999
	CANDLES_PERIOD = 300

	def initialize(key, secret, database)
		@key = key
		@secret = secret
		@database = database
	end

	def pair=(pair)
		@pair = pair
	end

	def candles(force_pair = nil)
		if force_pair
			use_pair = force_pair
		else
			use_pair = @pair
		end

		if use_pair == 'USDT'
			currency_pair = 'USDT_BTC'
		else
			currency_pair = "BTC_#{use_pair}"
		end

		public_api_call({
			:command => 'returnChartData',
			:currencyPair => currency_pair,
			:start => margin(CANDLES_MARGIN),
			:end => CANDLES_END,
			:period => CANDLES_PERIOD
						})
	end

	def glass
		public_api_call({
			:command => 'returnOrderBook',
			:currencyPair => "BTC_#{@pair}",
			:depth => 100
						})
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

	def history(from)
		private_api_call({
			:command => 'returnTradeHistory',
			:currencyPair => "BTC_#{@pair}",
			:start => from.to_time.to_i,
						 })
	end

	def buy(rate, amount)
		trade('buy', rate, amount)
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
			'Key' => @key,
			'Sign' => OpenSSL::HMAC.hexdigest(digest, @secret, params),
			'Content-Type' => 'application/json'
		}
	end

	def margin(timestamp)
		(Time.now - timestamp).to_i
	end
end