require_relative 'Abstract'

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
		validate = initiator.validate

		@rate =   raw_order[0]
		@amount = raw_order[1]

		validate.float(raw_order[0])
		validate.int(raw_order[1])

		@rate =   initiator.num(@rate)
		@amount = initiator.num(@amount)
	end

end