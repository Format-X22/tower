require_relative '_'

class Algorithm::Stock::Executor < Algorithm::Abstract

	def initialize(context)
		super()
		@context = context
		@profile = Model::Profile.new(context)
		@pairs   = Model::Pairs.new(context)
		@trader  = Model::Trader.new(context)
		@twitter = Model::Twitter.new(context)
		@glass   = Model::Glass.new(context)
		@money   = Model::Money.new(context)
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