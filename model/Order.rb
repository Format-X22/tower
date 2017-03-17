require_relative '_'

class Model_Order < Model_Abstract
	attr_reader :list

	def initialize(context)
		super

		@list = @stock.orders.map do |order|
			Order.new(order)
		end
	end

	class Order
		include Util_Misc

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