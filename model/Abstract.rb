require_relative '_'

class Model_Abstract
	include Util_Misc

	attr_reader :db, :stock

	def initialize(context)
		@db = context.db
		@stock = context.stock
	end
end

class Model_AbstractAccessor
	include Util_Misc
end