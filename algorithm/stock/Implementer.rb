require_relative 'Executor'

class Implementer < Executor

	attr_reader :listed, :delisted

	def stop?
		profile.stop
	end

	def wait?
		profile.calm > now
	end

	def harvesting?
		harvesting_usd > 0
	end

	def stop_harvesting
		profile.harvesting_usd = 0
	end

	def delisted_in_bag?
		extract_delisted

		@delisted.length > 0
	end

	def listed_recently?
		result = false

		extract_listed
		add_new_pairs

		listed.each do |pair|
			if pairs.get_add_time(pair) > listed_actual_offset_time
				result = true
				break
			end
		end

		result
	end

	def mark_trade_off(pairs_off)
		pairs_off.each do |pair|
			pairs.stop_trade(pair)
		end
	end

	def sell(pairs_sell)
		pairs_sell.each do |pair|
			sell_order(pair)
		end
	end

	def all_traded_pairs
		pairs.traded
	end

	def wait_listed_hype_end
		offset = listed_hype_offset_time

		profile.calm = offset

		all_traded_pairs.each do |pair|
			pairs.min_calm_for(pair, offset)
		end
	end

	def ratably_decrement_pairs_on(usd)
		#
	end

	def harvesting_usd
		profile.harvesting_usd
	end

	def ratably_sell_part(pairs, usd)
		#
	end

	private

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

	def add_new_pairs
		listed.each do |pair|
			pairs.add(pair)
		end
	end

	def listed_hype_offset_time
		now + profile.listed_hype_offset
	end

	def listed_actual_offset_time
		now - profile.listed_actual_offset
	end






















=begin

	def sell_to(pairs, usd)
		btc = usd / usdt_rate
		pair_btc =  btc / pairs.length

		pairs.each do |pair|
			sell_order(pair, pair_btc)
		end
	end

=end

end