require_relative '_'

class Model::Config < Model::Abstract

	def get
		struct = Util::HashStruct.new(@db.config)

		#
	end

end