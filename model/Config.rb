require_relative '_'

class Model_Config < Model_Abstract

	def initialize(context)
		super(context)

		raw = Util_HashStruct.new(@db.config)
	end

end