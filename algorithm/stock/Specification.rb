require_relative '_'

class Algorithm_Stock_Specification < Algorithm_Stock_Implementer

	def run(&chain)
		if stop? or wait?
			return
		end

		if delisted_in_bag?
			sell_delisted
			stop_delisted
			return
		end

		if listed_recently?
			sell_all_traded
			wait_listed_hype_end
			return
		end

		if harvesting?
			rateably_sell_harvesting_part
			stop_harvesting
			return
		end

		chain.call
	end

end