require_relative '_'

class Algorithm_Global_Specification < Algorithm_Global_Implementer

	def run
		if stop?
			return
		end

		each_stock do
			each_profile do
				stock_trade do
					each_pair do
						pair_trade
					end
				end
			end
		end
	end

end