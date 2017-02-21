require 'date'
require_relative 'AbstractDSL'

class Implementer < AbstractDSL

	def state(state = nil)
		if state
			meta.state = state
		else
			meta.state
		end
	end

	def buy
		#
	end

	def sell
		#
	end

	def sell!
		#
	end

	def replace
		case order.type
			when 'buy'
				rate = optimal_ask_rate
				amount = order.rate * order.amount / rate

				replace_order(order.id, rate, amount)
			when 'sell'
				rate = meta.low * profile.top_price * btc_sigma
				amount = order.amount + money
				min = optimal_bid_rate * profile.min_sell_mul

				if rate < min
					rate = min
				end

				replace_order(order.id, rate, amount)
			else
		end
	end

	def remove
		#
	end

	def stop_trade!
		#
	end

	def red_candle?
		#
	end

	def open_order?
		#
	end

	def delisted?
		#
	end

	def btc_pump?
		#
	end

	def new_coin_add?
		#
	end

	def stop?
		profile.stop
	end

	def wait?
		meta.calm > DateTime.now.new_offset(0)
	end

end