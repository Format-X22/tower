require_relative '_'

class Model::Glass < Model::Abstract

	def get
		raw = Util::HashStruct.new(@stock.glass)

		asks = raw.asks.map do |order|
			GlassOrder.new(order)
		end

		bids = raw.bids.map do |order|
			GlassOrder.new(order)
		end

		GlassContainer.new(asks, bids)
	end

	class GlassContainer
		attr_reader :asks, :bids

		def initialize(asks, bids)
			@asks = asks
			@bids = bids
		end

		def top_ask_rate
			@asks.first.rate
		end

		def top_bid_rate
			@bids.first.rate
		end

	end

	class GlassOrder < Model::AbstractAccessor
		attr_reader :rate, :amount

		def initialize(raw_order)
			@rate   = num(raw_order[0])
			@amount = num(raw_order[1])
		end

	end

end