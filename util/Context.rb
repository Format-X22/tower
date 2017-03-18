require_relative '_'

class Util_Context
	attr_accessor :keys, :db, :stock

	def initialize(keys = nil, db = nil, stock = nil)
		@keys = keys
		@db = db
		@stock = stock

		@swapped_pair = nil
	end

	def pair=(value)
		@db.pair = value
		@stock.pair = value
	end

	def swap_pair(pair = nil)
		if @swapped_pair
			self.pair = @swapped_pair
			@swapped_pair = nil
		else
			self.pair = pair
			@swapped_pair = pair
		end
	end

	def profile=(value)
		@db.profile = value
	end

end