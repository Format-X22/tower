require_relative 'Abstract'

class Money < Abstract

	def get
		num(@stock.money)
	end

end