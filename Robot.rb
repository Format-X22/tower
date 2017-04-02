PAIRS = {
	#
}

require 'date'
require 'uri'
require 'openssl'
require 'net/http'
require 'json'
require 'twitter'

class Robot
	attr_reader :pair

	def initialize
		while true
			begin
				connect_to_twitter
				check_delisting
				trade
				sleep 0.5
			rescue Exception => exception
				p exception.message
				sleep 5
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

	def check_delisting
		@twitter.user_timeline('poloniex').each do |tweet|
			if tweet.text.match('delist')
				pairs do
					sell if /\s#{pair}|,#{pair}|:#{pair}/.match(tweet.text) and money > 0
				end
			end
		end
	end

	def trade
		pairs do
			sell if (money > 0) and (rate >= target)
		end
	end

	def rate
		ticker[pair_trade_name]['last'].to_f
	end

	def target
		PAIRS[pair].to_f
	end

	def ticker
		public_api(command: 'returnTicker')
	end

	def money
		api(command: 'returnAvailableAccountBalances')['exchange'][pair.to_s].to_f
	end

	def sell
		api(
			command:      'sell',
			currencyPair: pair_trade_name,
			rate:         '%1.8f' % (rate * 0.75),
			amount:       '%1.8f' % money
		)
	end

	def pairs(&block)
		PAIRS.keys.each do |pair|
			@pair = pair
			block.call
		end
	end

	def public_api(config)
		params = URI.encode_www_form(config)
		response = Net::HTTP.get(URI("https://poloniex.com/public?#{params}"))
		result = JSON.parse(response)

		check_request_result(result, config)
	end

	def api(config)
		config[:nonce] = (Time.now.to_f * 1000).to_i

		uri = URI('https://poloniex.com/tradingApi')
		headers = request_headers(config)
		request = Net::HTTP::Post.new(uri, headers)
		request.set_form_data(config)
		result = nil

		Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
			result = JSON.parse(http.request(request).body)
		end

		check_request_result(result, config)
	end

	def check_request_result(result, config)
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
			'Key' => 'VFYTOUL8-QMXD4PCQ-LDEMD2GG-MJD9IXY3',
			'Content-Type' => 'application/json',
			'Sign' => OpenSSL::HMAC.hexdigest(
				OpenSSL::Digest.new('sha512'),
				'9f7d888231869a591a414a691ec43a9eb02479016b610da7903edc8d656ac713a0beb163645ae963cb2430d476524572a941d33b200b666dae470cf52e8ce22e',
				URI.encode_www_form(body)
			)
		}
	end

	def pair_trade_name
		if pair == 'BTC'
			'USDT_BTC'
		else
			"BTC_#{pair}"
		end
	end

end

Robot.new