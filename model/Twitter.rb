require_relative '_'
require 'twitter'

class Model_Twitter < Model_Abstract

	def initialize(context)
		super

		keys = @keys.twitter

		@twitter = Twitter::REST::Client.new do |config|
			config.consumer_key        = keys.consumer_key
			config.consumer_secret     = keys.consumer_secret
			config.access_token        = keys.access_token
			config.access_token_secret = keys.access_token_secret
		end
	end

	def news
		@twitter.user_timeline(@stock.twitter_name)
	end

end