require_relative '_'
require 'pg'

class DataBase_Connection

	def initialize(db_name)
		@connection = PG.connect(dbname: db_name)
	end

	def exec(query, params = [])
		if params.length > 0
			@connection.exec_params(query, params)
		else
			@connection.exec(query)
		end
	end

end