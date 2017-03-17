require_relative '_'

class Model_Config < Model_Abstract
	attr_reader :rescue_sleep, :stop

	def initialize(context)
		super(context)

		raw = Util_HashStruct.new(@db.config)

		@stop = raw.stop
		@rescue_sleep = num(raw.rescue_sleep)
	end

	def stocks
		registry = Stock_Registry.list

		@db.active_stocks.map do |row|
			raw = Util_HashStruct.new(row)

			symbol = raw.name.to_sym
			cls = registry[symbol]
			keys = @keys[symbol]
			instance = cls.new(keys.key, keys.secret)

			stocks.push(instance)
		end
	end

	def profiles
		@db.active_profiles(@stock.name).map do |row|
			Util_HashStruct.new(row)
		end
	end

end