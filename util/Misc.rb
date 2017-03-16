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

	def date_to_i(date)
		if date.is_a? Integer
			return date
		end

		if date.is_a? BigDecimal
			return date.to_i
		end

		if date.is_a? Date or date.is_a? DateTime
			return date.to_time.to_i
		end

		raise 'Unknown date type'
	end

end