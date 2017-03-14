class FlexReadStruct

	def initialize(hash)
		@mem = {}

		hash.each_pair do |key, value|
			@mem[key.to_sym] = value
		end
	end

	def method_missing(symbol)
		if @mem.key?(symbol)
			@mem[symbol]
		else
			raise "Bad key #{symbol.to_s}"
		end
	end

end