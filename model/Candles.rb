require_relative 'Abstract'

class Candles < Abstract

	def sync
		#
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
				low_ratio = low_candle.low / candle.usdt.average
			end

			ratio = candle.low / candle.usdt.average

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

end