require_relative 'Executor'

class Implementer < Executor

	@listed = nil
	@delisted = nil

	def stop?
		profile.stop
	end

	def wait?
		profile.calm > now
	end

	def harvesting?
		profile.harvesting_usd > 0
	end

	def listed
		return @listed if @listed

		@listed = []

		stock_news.each do |post|
			if listing_words?(post)
				@listed << extract_pairs(post)
			end
		end

		@listed.flatten!.uniq!

		@listed = @listed - listed_pairs
	end

	def delisted
		return @delisted if @delisted

		@delisted = []

		stock_news.each do |post|
			if delisting_words?(post)
				@delisted << extract_pairs(post)
			end
		end

		@delisted.flatten!.uniq!

		@delisted = @delisted & traded_pairs
	end

	def sell(pairs)
		pairs.each do |pair|
			sell_order(pair)
		end
	end

	def sell_to(pairs, usd)
		btc = usd / usdt_rate
		pair_btc =  btc / pairs.length

		pairs.each do |pair|
			sell_order(pair, pair_btc)
		end
	end

	def harvesting_usd
		profile.harvesting_usd
	end

end