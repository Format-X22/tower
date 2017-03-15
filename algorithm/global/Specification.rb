require_relative '_'

class Algorithm::Global::Specification < Algorithm::Global::Implementer

	def trade
		if stop?
			return
		end

		each_stock do
			stock_trade

			each_pair do
				pair_trade
			end
		end
	end

end