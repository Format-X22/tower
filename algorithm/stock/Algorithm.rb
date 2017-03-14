require_relative 'Implementer'

class Algorithm < Implementer

	def trade
		if stop? or wait?
			return false
		end

		if delisted_in_bag?
			stop_delisted
			sell_delisted
			return false
		end

		if listed_recently?
			sell_all_traded
			wait_listed_hype_end
			return false
		end

		if harvesting?
			ratably_sell_harvesting_part
			stop_harvesting
			return false
		end

		true
	end

end