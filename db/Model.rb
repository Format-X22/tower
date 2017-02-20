require_relative './Abstract'

class Model < Abstract

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

		if result['stop'] == 't'
			result['stop'] = true
		else
			result['stop'] = false
		end

		result
	end

	def all_pairs
		get_many('SELECT pair FROM pairs WHERE stock=$1 AND profile=$2 AND trade = TRUE', @profile_context)
	end

end