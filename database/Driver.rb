require_relative '_'

class DataBase_Driver

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

	def meta
		get_single('SELECT * FROM meta WHERE stock=$1 AND profile=$2 AND pair=$3', @pair_context)
	end

	def meta=(values)
		data = make_params(values)

		unless data
			throw 'Try save empty meta'
		end

		exec("UPDATE meta SET #{data} WHERE stock=$1 AND profile=$2 AND pair=$3", @pair_context)
	end

	def start_trade
		exec('UPDATE pairs SET trade = TRUE WHERE stock=$1 AND profile=$2 AND pair=$3', @pair_context)
	end

	def stop_trade
		exec('UPDATE pairs SET trade = FALSE WHERE stock=$1 AND profile=$2 AND pair=$3', @pair_context)
	end

	def profile
		result = get_single('SELECT * FROM profile WHERE stock=$1 AND profile=$2', @profile_context)

		to_boolean(result, 'stop')

		result
	end

	def all_pairs
		get_many('SELECT pair FROM pairs WHERE stock=$1 AND profile=$2 AND trade = TRUE', @profile_context)
	end

	private

	def get_single(query, params = [])
		result = nil

		exec(query, params).each do |row|
			result = row
		end

		result
	end

	def get_many(query, params = [])
		result = []

		exec(query, params).each do |row|
			result.push(row)
		end

		result
	end

	def exec(query, params = [])
		@connection.exec(query, params)
	end

	def to_boolean(hash, key)
		if hash[key] == 't'
			hash[key] = true
		else
			hash[key] = false
		end
	end

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

end