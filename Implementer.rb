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
		delisted = false

		stock_news.each do |post|
			if delisting_words?(post.text) and pair_name?(post.text)
				delisted = true
			end
		end

		delisted
	end

	def new_coin_add?
		new_coin = false

		stock_news.each do |post|
			if add_coin_words?(post.text) and now - profile.new_coin_wait_offset < post.date
				new_coin = true
			end
		end

		new_coin
	end

	def btc_pump?
		#
	end

	def stop?
		profile.stop
	end

	def wait?
		meta.calm > now
	end

end