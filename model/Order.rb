require_relative '_'

class Model_Order < Model_Abstract

	def get
		@stock.orders.map do |order|
			OrderAccessor.new(order)
		end
	end

	class OrderAccessor < Model_AbstractAccessor
		attr_reader :id, :rate, :amount, :type

		def initialize(raw)
			struct = Util_HashStruct.new(raw)

			@id     = num(struct.orderNumber)
			@rate   = num(struct.rate)
			@amount = num(struct.amount)
			@type   = struct.type
		end
	end

end