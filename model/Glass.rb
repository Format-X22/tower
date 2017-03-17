require_relative '_'

class Model_Glass < Model_Abstract
	attr_reader :asks, :bids

	def initialize(context)
		super

		raw = Util_HashStruct.new(@stock.glass)

		@asks = raw.asks.map do |order|
			Order.new(order)
		end

		@bids = raw.bids.map do |order|
			Order.new(order)
		end
	end

	def top_ask_rate
		@asks.first.rate
	end

	def top_bid_rate
		@bids.first.rate
	end

	class Order
		include Util_Misc

		attr_reader :rate, :amount

		def initialize(raw_order)
			@rate   = num(raw_order[0])
			@amount = num(raw_order[1])
		end

	end

end