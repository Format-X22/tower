require_relative '_'

class Model_Profile < Model_Abstract
	attr_reader(
		:low_reset_time,
		:stop,
		:top_price,
		:min_sell_mul,
		:calm,
		:harvesting_usd,
		:listed_actual_offset,
		:listed_hype_offset
	)

	def initialize(context)
		super

		raw = Util_HashStruct.new(@db.profile)

		@low_reset_time       = parse_date(raw.low_reset_time)
		@stop                 = raw.stop
		@top_price            = num(raw.top_price)
		@min_sell_mul         = num(raw.min_sell_mul)
		@calm                 = parse_date(raw.calm)
		@harvesting_usd       = num(raw.harvesting_usd)
		@listed_actual_offset = num(raw.listed_actual_offset)
		@listed_hype_offset   = num(raw.listed_hype_offset)
	end

	def harvesting_usd=(value)
		@db.profile('harvesting_usd', value)
	end

	def calm=(value)
		@db.profile('calm', value)
	end

end