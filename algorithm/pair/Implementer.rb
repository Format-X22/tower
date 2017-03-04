require 'date'
require_relative 'Executor'

class Implementer < Executor

	def state(state = nil)
		unless state
			return meta.state
		end

		case state
			when 'hold'
				meta.sell_start_time = now
			when 'calm'
				meta.calm = now + meta.calm_offset
			else #
		end

		meta.extra_btc = 0
		meta.state = state
	end

	def buy
		rate = optimal_ask_rate
		unused_btc = earned_capital(meta.sell_start_time) + meta.extra_btc
		amount = unused_btc / rate

		buy_order(rate, amount)
	end

	def sell
		sell_order(sell_rate, money)
	end

	def replace
		case order.type
			when 'buy'  then replace_buy
			when 'sell' then replace_sell
			else #
		end
	end

	def red_candle?
		tick.open > tick.close
	end

	def open_order?
		order.open.length > 0
	end

	def stop?
		profile.stop
	end

	def wait?
		meta.calm > now
	end

	private

	def replace_buy
		rate = optimal_ask_rate
		amount = order.rate * order.amount / rate

		replace_order(order.id, rate, amount)
	end

	def replace_sell
		rate = sell_rate
		amount = order.amount + money

		replace_order(order.id, rate, amount)
	end

	def sell_rate
		rate = meta.low * profile.top_price * btc_sigma
		min = optimal_bid_rate * profile.min_sell_mul

		if rate < min
			rate = min
		end

		rate
	end

	def optimal_ask_rate
		glass.asks.first.rate
	end

	def optimal_bid_rate
		glass.bids.first.rate
	end

	def earned_capital(from)
		result = 0

		history(from).sell.each do |event|
			result += event.total * (1 - event.fee)
		end

		result
	end

	def btc_sigma
		low_tick.usdt.low / tick.usdt.low
	end

end