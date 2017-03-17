require_relative '_'

class Model_Pairs < Model_Abstract

	def all
		parse @db.pairs
	end

	def traded
		parse @db.pairs(traded: true)
	end

	def listed
		parse @db.pairs(listed: true)
	end

	def delisted
		parse @db.pairs(delisted: true)
	end

	def usdt
		#
	end

	def sync_listed(pairs)
		#
	end

	def sync_delisted(pairs)
		#
	end

	def set_min_calm(pair, calm)
		#
	end

	def decrement_btc(pair, btc)
		#
	end

	private

	def parse(data)
		raw = Util_HashStruct.new(data)

		raw.traded   = raw.traded
		raw.listed   = raw.listed
		raw.delisted = raw.delisted
		raw.add_time = parse_date(raw.add_time)
	end

end