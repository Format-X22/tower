require_relative '_'

class Model::Order < Model::Abstract

	def get
		@stock.orders.map do |order|
			OrderAccessor.new(order)
		end
	end

	class OrderAccessor < Model::AbstractAccessor
		attr_reader :id, :rate, :amount, :type

		def initialize(raw)
			struct = OpenStruct.new(raw)

			@id =     num(struct.orderNumber)
			@rate =   num(struct.rate)
			@amount = num(struct.amount)
			@type =   struct.type
		end
	end

end