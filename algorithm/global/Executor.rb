require_relative '_'

class Algorithm_Global_Executor < Algorithm_Abstract
	attr_reader :context

	def initialize(keys, db_name)
		super()

		connection = DataBase_Connection.new(db_name)
		database   = DataBase_Driver.new(connection)

		@context = Model_Context.new(keys, database)
		@config  = Model_Config.new(@context)
		@logger  = Model_Logger.new(@context)
		@pairs   = Model_Pairs.new(@context)
	end

	def config
		@config
	end

	def pairs
		@pairs
	end

	def log(message)
		@logger.log(message)
	end

	def log_error(error)
		@logger.log_error(error)
	end

end