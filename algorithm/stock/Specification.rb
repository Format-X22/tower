require_relative '_'

class Algorithm::Stock::Specification < Algorithm::Stock::Implementer

	def trade
		if stop? or wait?
			return false
		end

		if delisted_in_bag?
			sell_delisted
			stop_delisted
			return false
		end

		if listed_recently?
			sell_all_traded
			wait_listed_hype_end
			return false
		end

		if harvesting?
			rateably_sell_harvesting_part
			stop_harvesting
			return false
		end

		true
	end

end