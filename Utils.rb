require 'date'
require 'bigdecimal'

module Utils

	def pair_orders(pair, all_orders)
		all_orders["BTC_#{pair}"]
	end

	def is_red_candle(candle)
		candle['open'] > candle['close']
	end

	def first_in_glass(type)
		num(@polo.glass[type].first.first)
	end

	def exit_when_stop
		exit if @profile['stop']
	end

	def parse_date(date)
		unless date
			return nil
		end

		DateTime.strptime(date, '%Y-%m-%d %H:%M:%S')
	end

	def num(number)
		number = (number or 0)

		BigDecimal.new(number.to_s)
	end

	def log_exception(exception, message_prefix = '')
		message = "#{message_prefix}#{exception.message}"

		p message

		if @database
			@database.log_error("#{message} --- #{exception.backtrace.inspect}")
		end
	end

	def time_offset
		3.0 / 24
	end

	def one_second
		1.0 / 24.0 / 60.0 / 60.0
	end

end