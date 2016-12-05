require 'pg'

class Database

	def initialize(db_name)
		@connection = PG.connect(:dbname => db_name)
	end

	def meta(pair, values = nil)
		if values
			data = []

			values.each do |key, value|
				data.push("#{key}='#{value}'") if value
			end

			if data.length == 0
				log_error('Try save empty meta')
				return
			end

			query = data.join(', ')
			exec("UPDATE meta SET #{query} WHERE pair = $1", [pair])
		else
			result = nil

			exec('SELECT * FROM meta WHERE pair = $1', [pair]).each do |row|
				result = row
			end

			result
		end
	end

	def pairs
		result = []

		exec('SELECT pair FROM pairs WHERE trade = TRUE').values.each do |row|
			result.push(row[0])
		end

		result
	end

	def log(text)
		exec('INSERT INTO log_text (text) VALUES ($1)', [text])
	end

	def log_warn(text)
		exec('INSERT INTO log_text (type, text) VALUES ($1, $2)', ['WARN', text])
	end

	def log_error(text)
		exec('INSERT INTO log_text (type, text) VALUES ($1, $2)', ['ERROR', text])
	end

	def log_trade(type, pair, btc)
		exec('INSERT INTO log_trade (type, pair, btc) VALUES ($1, $2, $3)', [type, pair, btc])
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