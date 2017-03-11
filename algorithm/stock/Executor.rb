require_relative '../Abstract'

class Executor < Abstract

	attr_reader :listed, :delisted

	def profile
		#
	end

	def pairs
		#
	end

	def sell_order(pair)
		#
	end

	def stock_news
		#
	end

	def extract_listed
		@listed = []

		stock_news.each do |post|
			if listing_words?(post)
				@listed << extract_pairs(post)
			end
		end

		@listed.flatten!.uniq!

		@listed = @listed - pairs.all
	end

	def extract_delisted
		@delisted = []

		stock_news.each do |post|
			if delisting_words?(post)
				@delisted << extract_pairs(post)
			end
		end

		@delisted.flatten!.uniq!
		@delisted = @delisted & pairs.traded
	end

	private

	def listing_words?(post)
		text = post.text

		text.match('added') and text.match('/BTC')
	end

	def delisting_words?(post)
		post.text.match('delist')
	end

	def extract_pairs(post)
		text = post.text
		result = []

		all_traded_pairs.each do |pair|
			result << text.scan(/\s#{pair}|,#{pair}|:#{pair}/)
		end

		result.flatten.uniq
	end

end