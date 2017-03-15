require_relative '_'

module Util_Misc

	def num(number)
		BigDecimal.new(number.to_s)
	end

	def now
		DateTime.now.new_offset(0)
	end

	def parse_date(date)
		DateTime.strptime(date, '%Y-%m-%d %H:%M:%S')
	end

	def readable_num(num)
		'%1.8f' % num.to_f
	end

	def timestamp_back(timestamp)
		(Time.now - timestamp).to_i
	end

	def date_to_i(date)
		if date.is_a? Integer
			date
		else
			date.to_time.to_i
		end
	end

end