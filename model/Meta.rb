require_relative 'Abstract'

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
		validate = initiator.validate

		@state           = raw['state']
		@sell_start_time = raw['sell_start_time']
		@calm            = raw['calm']
		@calm_offset     = raw['calm_offset']
		@extra_btc       = raw['extra_btc']
		@low             = raw['low']

		@sell_start_time = initiator.parse_date(@sell_start_time)
		@calm            = initiator.parse_date(@calm)

		validate.string(@state)
		validate.date(@sell_start_time)
		validate.date(@calm)
		validate.int(@calm_offset)
		validate.int(@extra_btc)
		validate.float(@low)

		@calm_offset = initiator.num(@calm_offset)
		@extra_btc   = initiator.num(@extra_btc)
		@low         = initiator.num(@low)

		@initiator = initiator
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