require_relative 'Abstract'

class Trader < Abstract

	def stop_trade
		@db.stop_trade
	end

	def buy(rate, amount)
		@stock.buy(rate, amount)

		@db.log_trade('BUY', rate * amount)
	end

	def sell(rate, amount)
		@stock.sell(rate, amount)

		@db.log_trade('SELL', rate * amount)
	end

	def replace(id, rate, amount)
		@stock.replace(id, rate, amount)
	end

end