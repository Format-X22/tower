require_relative '_'

class Model::Config < Model::Abstract

	def initialize(context, stock_keys)
		super(context)

		#
	end

	def get
		struct = Util::HashStruct.new(@db.config)

		#
	end

end