require_relative '_'
require 'pg'

class DataBase_Connection
	attr_reader :connection

	def initialize(db_name)
		@connection = PG.connect(:dbname => db_name)
	end

end