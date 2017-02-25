class Glass < Abstract

	def get
		raw = @stock.glass

		asks = raw['asks'].map do |order|
			GlassOrder.new(order, self)
		end

		bids = raw['bids'].map do |order|
			GlassOrder.new(order, self)
		end

		GlassContainer.new(asks, bids)
	end

end

class GlassContainer
	attr_reader :asks, :bids

	def initialize(asks, bids)
		@asks = asks
		@bids = bids
	end

end

class GlassOrder
	attr_reader :rate, :amount

	def initialize(raw_order, initiator)
		@rate =   initiator.validate_float(raw_order[0])
		@amount = initiator.validate_int(raw_order[1])
	end

end