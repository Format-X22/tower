require 'twitter'

class Guard

	def initialize
		@twitter = Twitter::REST::Client.new do |config|
			config.consumer_key        = 'YOUR_CONSUMER_KEY'
			config.consumer_secret     = 'YOUR_CONSUMER_SECRET'
			config.access_token        = 'YOUR_ACCESS_TOKEN'
			config.access_token_secret = 'YOUR_ACCESS_SECRET'
		end
	end

	def check_de_listing
		status = 'ok'

		@twitter.user_timeline('poloniex').each do |tweet|
			if tweet.text.match('delist')
				targets = parse_de_listing_pairs(tweet.text)

				if is_coins_in_bag(targets)
					de_listing_sell(targets)
					status = 'de_listing'
				end
			end
		end

		status
	end

	private

	def parse_de_listing_pairs(text)
		#
	end

	def is_coins_in_bag(coins)
		#
	end

	def de_listing_sell(targets)
		#
	end

end