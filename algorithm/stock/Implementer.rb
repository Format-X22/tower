require_relative 'Executor'

class Implementer < Executor

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

		delisted.length > 0
	end

	def listed_recently?
		result = false

		extract_listed
		add_new_pairs

		listed.each do |pair|
			add_time = pairs.get_add_time(pair)
			offset = profile.listed_actual_offset

			if add_time + offset > now
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
		calm = now + profile.listed_hype_offset

		profile.calm = calm

		all_traded_pairs.each do |pair|
			pairs.min_calm_for(pair, calm)
		end
	end

	def ratably_decrement_pairs_on(usd)
		btc = calc_btc(usd)

		pairs.decrement_all_on(btc)
	end

	def harvesting_usd
		profile.harvesting_usd
	end

	def ratably_sell_part(pairs, usd)
		btc = calc_btc(usd)

		ratably_sell_order(pairs, btc)
	end

	private

	def add_new_pairs
		listed.each do |pair|
			pairs.add(pair)
		end
	end

	def calc_btc(usd)
		usd / usdt_rate
	end

end