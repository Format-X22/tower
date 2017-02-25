class Meta < Abstract

	def get
		MetaAccessor.new(@db.meta, self)
	end

	def set(field, value)
		@db.meta(field, value)
	end

end

class MetaAccessor
	attr_reader :state, :sell_start_time, :calm, :calm_offset, :extra_btc, :low

	def initialize(raw, initiator)
		i = initiator

		@state =           raw['state']
		@sell_start_time = raw['sell_start_time']
		@calm =            raw['calm']
		@calm_offset =     raw['calm_offset']
		@extra_btc =       raw['extra_btc']
		@low =             raw['low']

		@sell_start_time = i.parse_date(@sell_start_time)
		@calm =            i.parse_date(@calm)

		i.validate_string(@state)
		i.validate_date(@sell_start_time)
		i.validate_date(@calm)
		i.validate_int(@calm_offset)
		i.validate_int(@extra_btc)
		i.validate_float(@low)

		@initiator = i
	end

	def state=(value)
		@initiator.set('state', value)
	end

	def sell_start_time=(value)
		@initiator.set('sell_start_time', value)
	end

	def calm=(value)
		@initiator.set('calm', value)
	end

	def calm_offset=(value)
		@initiator.set('calm_offset', value)
	end

	def extra_btc=(value)
		@initiator.set('extra_btc', value)
	end

	def low=(value)
		@initiator.set('low', value)
	end

end