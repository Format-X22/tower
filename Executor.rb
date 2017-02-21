class Executor

	def initialize(pair:)
		@pair = pair
	end

	def profile
		#
	end

	def meta
		#
	end

	def order
		#
	end

	def money
		#
	end

	def btc_sigma
		#
	end

	def optimal_ask_rate
		#
	end

	def optimal_bid_rate
		#
	end

	def replace_order(id, rate, amount)
		#
	end

	def stock_news
		#
	end

	def delisting_words?(text)
		text.match('delist')
	end

	def pair_name?(text)
		/\s#{@pair}|,#{@pair}|:#{@pair}/.match(text)
	end

	def add_coin_words?(text)
		text.match('added') and text.match('/BTC')
	end

	def now
		DateTime.now.new_offset(0)
	end
end