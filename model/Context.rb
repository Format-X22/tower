class Context < Abstract
	attr_reader :db, :polo, :stock, :profile, :pair

	def initialize(db:, polo:, stock:, profile:, pair:)
		@db = db
		@polo = polo
		@stock = stock
		@profile = profile
		@pair = pair
	end

end