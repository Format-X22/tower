class Utils

	def num(number)
		BigDecimal.new(number.to_s)
	end

	def now
		DateTime.now.new_offset(0)
	end

end