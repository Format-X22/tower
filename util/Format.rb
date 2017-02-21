require 'date'
require 'bigdecimal'

class Format

	def self.readable_num(num)
		'%1.8f' % num.to_f
	end

	def self.time_back(timestamp)
		(Time.now - timestamp).to_i
	end

	def self.date_to_i(date)
		if date.is_a? Integer
			date
		else
			date.to_time.to_i
		end
	end

	def self.parse_date(date)
		DateTime.strptime(date, '%Y-%m-%d %H:%M:%S')
	end

	def self.num(number = '0')
		BigDecimal.new(number.to_s)
	end

end