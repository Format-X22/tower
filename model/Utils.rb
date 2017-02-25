class Utils

	def num(number)
		BigDecimal.new(number.to_s)
	end

	def now
		DateTime.now.new_offset(0)
	end

	def parse_date(date)
		DateTime.strptime(date, '%Y-%m-%d %H:%M:%S')
	end

	def validate_date(value)
		unless value.is_a? Date
			raise "#{value} is not a date"
		end

		value
	end

	def validate_int(value)
		unless value.is_a? Integer
			raise "#{value} is not a int"
		end

		value
	end

	def validate_float(value)
		unless value.is_a? Float
			raise "#{value} is not a float"
		end

		value
	end

	def validate_string(value)
		unless value.is_a? String
			raise "#{value} is not a string"
		end

		value
	end

end