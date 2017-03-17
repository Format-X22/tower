require_relative '_'

class Model_Context
	attr_accessor :db, :stock

	def initialize(db = nil, stock = nil)
		@db = db
		@stock = stock
	end

	def pair=(value)
		@db.pair = value
		@stock.pair = value
	end

	def profile=(value)
		@db.profile = value
	end

end