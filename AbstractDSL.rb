class AbstractDSL

	def initialize(dsl)
		@dsl = dsl
	end

	def method_missing(method, *args)
		if @dsl.respond_to? method
			@dsl.send(method, *args)
		else
			raise "No method '#{method}' for #{self.class.name}"
		end
	end

end