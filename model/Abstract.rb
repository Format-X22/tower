require_relative '_'

class Model::Abstract
	include Util::Misc

	attr_reader :db, :stock

	def initialize(context)
		@db = context.db
		@stock = context.stock
	end
end

class Model::AbstractAccessor
	include Util::Misc
end