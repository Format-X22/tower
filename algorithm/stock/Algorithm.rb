require_relative 'Implementer'

class Algorithm < Implementer

	def trade
		if stop? or wait?
			return false
		end

		if delisted_in_bag?
			mark_trade_off(delisted)
			sell(delisted)
			return false
		end

		if listed_recently?
			sell(all_pairs_in_bag)
			wait_listed_hype_end
			return false
		end

		if harvesting?
			ratably_decrement_pairs_on(harvesting_usd)
			ratably_sell_part(all_pairs_in_bag, harvesting_usd)
			return false
		end

		true
	end

end