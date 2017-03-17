require_relative '_'

class Model_Context
	attr_accessor :keys, :db, :stock

	def initialize(keys = nil, db = nil, stock = nil)
		@keys = keys
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