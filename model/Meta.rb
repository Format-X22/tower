require_relative '_'

class Model_Meta < Model_Abstract
	attr_reader :state, :sell_start_time, :calm, :calm_offset, :extra_btc, :low

	def initialize(context)
		super

		raw = Util_HashStruct.new(@db.meta)

		@state           = raw.state
		@sell_start_time = parse_date(raw.sell_start_time)
		@calm            = parse_date(raw.calm)
		@calm_offset     = num(raw.calm_offset)
		@extra_btc       = num(raw.extra_btc)
		@low             = num(raw.low)
	end

	def state=(value)
		@db.meta('state', value)
	end

	def sell_start_time=(value)
		@db.meta('sell_start_time', value)
	end

	def calm=(value)
		@db.meta('calm', value)
	end

	def calm_offset=(value)
		@db.meta('calm_offset', value)
	end

	def extra_btc=(value)
		@db.meta('extra_btc', value)
	end

	def low=(value)
		@db.meta('low', value)
	end

end