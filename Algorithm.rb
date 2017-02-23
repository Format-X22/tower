require_relative 'Implementer'

class Algorithm < Implementer

	def trade
		if delisted?
			stop_trade!
			return
		end

		if stop? or wait?
			return
		end

		if new_coin_add?
			sell!
			return
		end

		unless open_order?
			next_state
		end

		trade_by_state
	end

	def next_state
		case state
			when 'buy'  then state 'hold'
			when 'hold' then state 'calm'
			when 'calm'
				if red_candle?
					state 'buy'
				end
			else
		end
	end

	def trade_by_state
		if open_order?
			replace
			return
		end

		case state
			when 'buy'  then buy
			when 'hold' then sell
			else
		end
	end

end