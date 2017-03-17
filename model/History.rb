require_relative '_'

class Model_History < Model_Abstract

	def from(date)
		buy  = []
		sell = []

		@stock.history(date).map do |row|
			raw = Util_HashStruct.new(row)

			raw.globalTradeID = num(raw.globalTradeID)
			raw.tradeID       = num(raw.tradeID)
			raw.date          = parse_date(raw.date)
			raw.rate          = num(raw.rate)
			raw.amount        = num(raw.amount)
			raw.total         = num(raw.total)
			raw.fee           = num(raw.fee)
			raw.orderNumber   = num(raw.orderNumber)
			raw.type          = raw.type
			raw.category      = raw.category

			case raw.type
				when 'buy'  then buy.push(raw)
				when 'sell' then sell.push(raw)
				else
					raise 'Unknown history order type'
			end
		end

		Util_HashStruct.new(buy: buy, sell: sell)
	end

end