class Abstract

	def initialize(connection, pair)
		@connection = connection
		@pair = pair
	end

	protected

	def exec(query, params = [])
		if params.length > 0
			@connection.exec_params(query, params)
		else
			@connection.exec(query)
		end
	end

end