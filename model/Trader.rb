require_relative 'Abstract'

class Trader

	def stop_trade
		#
	end

	def buy(rate, amount)
		#

		log_trade('BUY', rate * amount)
	end

	def sell(rate, amount)
		#

		log_trade('SELL', rate * amount)
	end

	def replace(id, rate, amount)
		#
	end

end