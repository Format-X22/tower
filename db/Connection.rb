require 'pg'

class Connection

	def initialize(db_name)
		@connection = PG.connect(:dbname => db_name)
	end

end