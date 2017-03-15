require_relative '_'

class Algorithm::Global::Executor < Algorithm::Abstract
	attr_reader :context

	def initialize(db_name, stocks_keys)
		super()

		connection = DataBase::Connection.new(db_name)
		database   = DataBase::Driver.new(connection)

		@context = Model::Context.new(database)
		@config  = Model::Config.new(@context, stocks_keys)
		@logger  = Model::Logger.new(@context)
		@pairs   = Model::Pairs.new(@context)
	end

	def config
		@config.get
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