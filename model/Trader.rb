require_relative '_'

class Model_Trader < Model_Abstract

	def stop_trade
		@db.stop_trade
	end

	def buy(rate, amount)
		@stock.buy(rate, amount)

		log_trade('BUY', rate * amount)
	end

	def sell(rate, amount)
		@stock.sell(rate, amount)

		log_trade('SELL', rate * amount)
	end

	def replace(id, rate, amount)
		@stock.replace(id, rate, amount)
	end

end