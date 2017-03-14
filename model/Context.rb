require_relative '_'

class Model::Context
	attr_reader :db, :stock

	def initialize(db, stock)
		@db = db
		@stock = stock
	end

	def pair=(value)
		@db.pair = value
		@stock.pair = value
	end

end