require_relative 'Utils'

class Abstract
	include UtilsMixed

	attr_reader :db, :stock, :validate

	def initialize(context)
		@db = context.db
		@stock = context.stock
		@validate = UtilsValidate.new
	end
end