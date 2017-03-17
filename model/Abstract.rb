require_relative '_'

class Model_Abstract
	include Util_Misc

	attr_reader :context, :db, :stock

	def initialize(context)
		@context = context
		@db = context.db
		@stock = context.stock
		@keys = context.keys
	end
end