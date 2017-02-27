require 'ostruct'
require_relative 'Abstract'

class Glass < Abstract

	def get
		raw = OpenStruct.new(@stock.glass)

		asks = raw.asks.map do |order|
			GlassOrder.new(order)
		end

		bids = raw.bids.map do |order|
			GlassOrder.new(order)
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
	include Utils

	attr_reader :rate, :amount

	def initialize(raw_order)
		@rate =   num(raw_order[0])
		@amount = num(raw_order[1])
	end

end