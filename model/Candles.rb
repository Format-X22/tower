require_relative '_'

class Model_Candles < Model_Abstract

	def last_candle
		sync
		Candle_With_Usd.new(@db.last_candle, usd_without_sync)
	end

	def usd
		sync
		usd_without_sync
	end

	def from(date)
		sync
		parse_candles(@db.candles(date))
	end

	def low_from(date)
		low_candle = nil
		low_ratio = nil

		from(date).each do |candle|
			unless low_candle
				low_candle = candle
				low_ratio = low_candle.low / candle.usd.average
			end

			ratio = candle.low / candle.usd.average

			if low_ratio > ratio
				low_candle = candle
				low_ratio = ratio
			end
		end

		if low_candle
			low_candle
		else
			last_candle
		end
	end

	private

	def swap_pair_to_usd
		@context.swap_pair(@stock.usd_pair_name)
	end

	def swap_pair_to_origin
		@context.swap_pair
	end

	def sync
		sync_current_pair
		swap_pair_to_usd
		sync_current_pair
		swap_pair_to_origin
	end

	def sync_current_pair
		last_timestamp = last_candle.timestamp
		candles = stock_candles(last_timestamp - 300)
		len = candles.length

		if len >= 1
			@db.update_last_candle(candles.first)

			if len > 1
				@db.add_candles(candles.drop(1))
			end
		else
			raise 'No candles data for timestamp'
		end
	end

	def usd_without_sync
		swap_pair_to_usd
		candle = @db.last_candle
		swap_pair_to_origin

		Candle.new(candle)
	end

	def stock_candles(from)
		parse_candles(@stock.candles(from))
	end

	def parse_candles(candles)
		usd = usd_without_sync

		candles.map do |raw|
			Candle_With_Usd.new(raw, usd)
		end
	end

	class Candle_With_Usd < Candle
		attr_reader :usd

		def initialize(data, usd)
			super(data)

			@usd = usd
		end

	end

	class Candle
		include Util_Misc

		attr_reader :timestamp, :high, :low, :open, :close, :volume, :average

		def initialize(data)
			raw = Util_HashStruct.new(data)

			@timestamp = num(raw.date)
			@high      = num(raw.high)
			@low       = num(raw.low)
			@open      = num(raw.open)
			@close     = num(raw.close)
			@volume    = num(raw.volume)
			@average   = num(raw.weightedAverage)
		end

	end

end