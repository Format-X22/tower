class Context
	attr_reader :db, :stock

	def initialize(db, stock)
		@db = db
		@stock = stock
	end

end