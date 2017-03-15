require_relative '_'

class Algorithm_Stock_Executor < Algorithm_Abstract

	def initialize(context)
		super()
		@context = context
		@profile = Model_Profile.new(context)
		@pairs   = Model_Pairs.new(context)
		@trader  = Model_Trader.new(context)
		@twitter = Model_Twitter.new(context)
		@glass   = Model_Glass.new(context)
		@money   = Model_Money.new(context)
	end

	def profile
		@profile.get
	end

	def pairs
		@pairs
	end

	def sell_order(pair, btc = nil)
		@context.pair = pair

		rate = @glass.get.top_bid_rate

		if btc
			@trader.sell(rate, btc / rate)
		else
			@trader.sell(rate, @money.get)
		end
	end

	def stock_news
		@twitter.news
	end

end