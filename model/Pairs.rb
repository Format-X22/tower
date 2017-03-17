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
		Model_Candles.new(@context).usdt
	end

	def sync_listed(pairs)
		@db.add_pairs(pairs, listed: true)
	end

	def sync_delisted(pairs)
		@db.add_pairs(pairs, delisted: true)
	end

	def set_min_calm(pair, min_calm)
		@context.pair = pair

		meta = Model_Meta.new(@context)

		if meta.calm < min_calm
			meta.calm = min_calm
		end
	end

	def decrement_btc(pair, btc)
		@context.pair = pair

		meta = Model_Meta.new(@context)

		meta.extra_btc = meta.extra_btc - btc
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