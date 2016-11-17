require 'pg'

class Database

	def initialize(db_name)
		@connection = PG.connect(:dbname => db_name)
	end

	def meta(pair, values = nil)
		if values
			data = []

			values.each do |key, value|
				data.push("#{key}='#{value}'")
			end

			if data.length == 0
				log_error('Попытка сохранения пустой меты')
				return
			end

			query = data.join(', ')
			exec("UPDATE meta SET #{query} WHERE pair = $1", [pair])
		else
			result = nil

			exec('SELECT low, calm, state FROM meta WHERE pair = $1', [pair]).each do |row|
				result = row
			end

			result
		end
	end

	def pairs
		result = []

		exec('SELECT pair FROM pairs').values.each do |row|
			result.push(row[0])
		end

		result
	end

	def log(text)
		exec('INSERT INTO log (text) VALUES ($1)', [text])
	end

	def log_error(text)
		exec('INSERT INTO log (type, text) VALUES ($1, $2)', ['E', text])
	end

	private

	def exec(query, *params)
		if params.length > 0
			@connection.exec_params(query, *params)
		else
			@connection.exec(query)
		end
	end

end