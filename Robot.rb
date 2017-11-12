require 'date'
require 'uri'
require 'openssl'
require 'net/http'
require 'json'
require 'twitter'

class Robot
	attr_reader :pair

	def initialize
		@key, @secret, @tw_1, @tw_2, @tw_3, @tw_4 = File.read('keys.txt').split("\n")
		@pairs = File.read('pairs.txt').split("\n")
		@pairs_re = /\s#{pair}|,#{pair}|:#{pair}/
		@sell_mul = 0.75

		while true
			begin
				cycle
				sleep 0.5
			rescue Exception => exception
				puts exception.message
				sleep 5
			end
		end
	end

	def cycle
		twitter = Twitter::REST::Client.new(
			consumer_key:        @tw_1,
			consumer_secret:     @tw_2,
			access_token:        @tw_3,
			access_token_secret: @tw_4
		)

		twitter.user_timeline('poloniex').each do |tweet|
			if tweet.text.match('delist')
				@pairs.each do |pair|
					@pair = pair
					sell if @pairs_re.match(tweet.text) and money > 0
				end
			end
		end
	end

	def money
		api(command: 'returnAvailableAccountBalances')['exchange'][pair].to_f
	end

	def sell
		api(
			command:      'sell',
			currencyPair: "BTC_#{pair}",
			rate:         '%1.8f' % (rate * @sell_mul),
			amount:       '%1.8f' % money
		)
	end

	def rate
		public_api(command: 'returnTicker')["BTC_#{pair}"]['last'].to_f
	end

	def public_api(config)
		params = URI.encode_www_form(config)
		response = Net::HTTP.get(URI("https://poloniex.com/public?#{params}"))
		result = JSON.parse(response)

		check_result(result, config)
	end

	def api(config)
		config[:nonce] = (Time.now.to_f * 1000).to_i

		uri = URI('https://poloniex.com/tradingApi')
		headers = make_headers(config)
		request = Net::HTTP::Post.new(uri, headers)
		request.set_form_data(config)
		result = nil

		Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
			result = JSON.parse(http.request(request).body)
		end

		check_result(result, config)
	end

	def check_result(result, config)
		unless result
			raise "Empty response #{config}"
		end

		if result.is_a?(Hash) and result['error']
			raise "#{result['error']} - #{config}"
		end

		result
	end

	def make_headers(body)
		{
			'Key' => @key,
			'Content-Type' => 'application/json',
			'Sign' => OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha512'), @secret, URI.encode_www_form(body))
		}
	end

end

Robot.new