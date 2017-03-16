require_relative '_'

class Util_HashStruct

	def self.getter(name, &body)
		define_method(name, &body)
	end

	def self.setter(name, &body)
		define_method("#{name}=", &body)
	end

	def initialize(hash)
		@mem = {}

		hash.each do |key, value|
			@mem[key] = value

			self.class.getter(key) do
				@mem[key]
			end

			self.class.setter(key) do |new_value|
				@mem[key] = new_value
			end
		end
	end

end