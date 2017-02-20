class Abstract

	def initialize(connection:, profile: nil, stock: nil, pair: nil)
		@connection = connection

		@profile_name = profile
		@stock_name = stock
		@pair_name = pair

		@stock_context = [@stock_name]
		@profile_context = [@stock_name, @profile_name]
		@pair_context = [@stock_name, @profile_name, @pair_name]
	end

	protected

	def make_params(values)
		data = []

		values.each do |key, value|
			data.push("#{key}='#{value}'") if value
		end

		if data.length == 0
			nil
		else
			data.join(', ')
		end
	end

	def get_single(query, params = [])
		result = nil

		exec(query, params).each do |row|
			result = row
		end

		result
	end

	def get_many(query, params = [])
		result = []

		exec(query, params).values.each do |row|
			result.push(row[0])
		end

		result
	end

	def exec(query, params = [])
		if params.length > 0
			@connection.exec_params(query, params)
		else
			@connection.exec(query)
		end
	end

end