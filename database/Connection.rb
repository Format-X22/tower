require_relative '../_'

class DataBase_Connection

	def initialize(db_name)
		@connection = PG.connect(:dbname => db_name)
	end

end