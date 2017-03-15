require_relative '_'

class Model_Config < Model_Abstract

	def initialize(context, stock_keys)
		super(context)

		#
	end

	def get
		struct = Util_HashStruct.new(@db.config)

		#
	end

end