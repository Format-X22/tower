# TODO Model
require_relative '_'

class Model_Candles < Model_Abstract

	def sync
		last_timestamp = @db.candles.last.date
		candles = @stock.candles(last_timestamp - 300)

		if candles.length == 1
			@db.update_last_candle(candles.first)
		end

		if candles.length > 1
			@db.add_candles(candles)
		end
	end

	def last_candle
		#
	end

	def from(date)
		#
	end

	def low_from(from)
		low_candle = nil
		low_ratio = nil

		from(from).each do |candle|
			unless low_candle
				low_candle = candle
				low_ratio = low_candle.low / candle.usdt.average # TODO Model
			end

			ratio = candle.low / candle.usdt.average # TODO Model

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

	def usdt
		#
	end

	class Candle
		include Util_Misc

		def initialize(raw)
			struct = Util_HashStruct.new(raw)

			#
		end

	end

end