require_relative '_'

class Model::Profile < Model::Abstract

	def get
		ProfileAccessor.new(@db)
	end

	class ProfileAccessor < Model::AbstractAccessor
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

		def initialize(db)
			@db = db

			struct = Util::HashStruct.new(@db.profile)

			@low_reset_time       = parse_date(struct.low_reset_time)
			@stop                 = struct.stop
			@top_price            = num(struct.top_price)
			@min_sell_mul         = num(struct.min_sell_mul)
			@calm                 = parse_date(struct.calm)
			@harvesting_usd       = num(struct.harvesting_usd)
			@listed_actual_offset = num(struct.listed_actual_offset)
			@listed_hype_offset   = num(struct.listed_hype_offset)
		end

		def harvesting_usd=(value)
			@db.profile('harvesting_usd', value)
		end

		def calm=(value)
			@db.profile('calm', value)
		end

	end

end