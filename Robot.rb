PAIRS = {
	BELA: 7000
}

require 'date'
require 'uri'
require 'openssl'
require 'net/http'
require 'json'
require 'twitter'

class Robot

	def initialize
		while true
			begin
				connect_to_twitter
				check_delisting
				trade
			rescue Exception => exception
				p exception.message
				sleep 5000
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

	def trade
		pairs.each do |pair|
			@pair = pair
			sell if (money > 0) and (rate >= target)
		end
	end

	def rate
		ticker["BTC_#{@pair}"]['last']
	end

	def target
		PAIRS[@pair]
	end

	def ticker
		public_api_call({
			command: 'returnTicker'
		})
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
			rate:         '0.00000001',
			amount:       '%1.8f' % money[@pair]
		})
	end

	def pairs
		PAIRS.keys.map do |key|
			key.to_s
		end
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
		{
			'Key': 'VFYTOUL8-QMXD4PCQ-LDEMD2GG-MJD9IXY3',
			'Sign': sign(body),
			'Content-Type': 'application/json'
		}
	end

	def sign(body)
		OpenSSL::HMAC.hexdigest(
			OpenSSL::Digest.new('sha512'),
			'9f7d888231869a591a414a691ec43a9eb02479016b610da7903edc8d656ac713a0beb163645ae963cb2430d476524572a941d33b200b666dae470cf52e8ce22e',
			URI.encode_www_form(body)
		)
	end

	def check_delisting
		tweets.each do |tweet|
			if delist_tweet(tweet)
				delisted_pairs(tweet).each do |pair|
					@pair = pair
					sell
				end
			end
		end
	end

	def tweets
		@twitter.user_timeline('poloniex')
	end

	def delist_tweet(tweet)
		tweet.text.match('delist')
	end

	def delisted_pairs(tweet)
		pairs.select do |pair|
			@pair = pair

			/\s#{@pair}|,#{@pair}|:#{@pair}/.match(tweet.text) and money > 0
		end
	end

end

Robot.new