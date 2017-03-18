require_relative '_'

class Algorithm_Stock_Implementer < Algorithm_Stock_Executor

	def stop?
		profile.stop
	end

	def wait?
		profile.calm > now
	end

	def harvesting?
		profile.harvesting_usd > 0
	end

	def delisted_in_bag?
		delisted_in_bag.length > 0
	end

	def delisted_in_bag
		pairs.sync_delisted(extract_delisted)

		pairs.traded & pairs.delisted
	end

	def sell_delisted
		delisted_in_bag.each do |pair|
			sell_order(pair)
		end
	end

	def stop_delisted
		delisted_in_bag.each do |pair|
			pairs.stop_trade(pair)
		end
	end

	def listed_recently?
		result = false

		pairs.sync_listed(extract_listed)

		pairs.listed.each do |pair|
			add_time = pair.add_time
			offset = profile.listed_actual_offset

			if add_time + offset > now
				result = true
				break
			end
		end

		result
	end

	def sell_all_traded
		pairs.traded.each do |pair|
			sell_order(pair)
		end
	end

	def wait_listed_hype_end
		calm = now + profile.listed_hype_offset

		profile.calm = calm

		pairs.traded.each do |pair|
			pairs.set_min_calm(pair, calm)
		end
	end

	def rateably_sell_harvesting_part
		traded = pairs.traded
		usd = profile.harvesting_usd
		btc = usd / pairs.usd.rate / traded.length

		traded.each do |pair|
			pairs.decrement_btc(pair, btc)
			sell_order(pair, btc)
		end
	end

	def stop_harvesting
		profile.harvesting_usd = 0
	end

	private

	def extract_listed
		pairs_from_news_by_cond(:listing_words?)
	end

	def extract_delisted
		pairs_from_news_by_cond(:delisting_words?)
	end

	def pairs_from_news_by_cond(method_symbol)
		data = []

		stock_news.each do |post|
			if self.method(method_symbol).call(post)
				data << extract_pairs(post)
			end
		end

		data.flatten!.uniq!
	end

	def listing_words?(post)
		text = post.text

		text.match('added') and text.match('/BTC')
	end

	def delisting_words?(post)
		post.text.match('delist')
	end

	def extract_pairs(post)
		result = []

		pairs.all.each do |pair|
			result << post.text.scan(/\s#{pair}|,#{pair}|:#{pair}/)
		end

		result.flatten!.uniq!
	end

end