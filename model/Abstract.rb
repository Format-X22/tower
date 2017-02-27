require_relative 'Utils'

class Abstract
	include Utils

	attr_reader :db, :stock

	def initialize(context)
		@db = context.db
		@stock = context.stock
	end
end