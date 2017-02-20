class Format
	singleton

	def readable_num(num)
		'%1.8f' % num.to_f
	end

	def time_back(timestamp)
		(Time.now - timestamp).to_i
	end

end