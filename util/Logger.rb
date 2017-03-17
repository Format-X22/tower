require_relative '_'

module Util_Logger

	def log(message, prefix = nil)
		log_universal(
			type: 'text',
			prefix: prefix,
			message: message,
			params: []
		)
	end

	def log_warn(message, prefix = nil)
		log_universal(
			type: 'text',
			prefix: prefix,
			message: message,
			params: ['WARN']
		)
	end

	def log_error(message, prefix = nil)
		log_universal(
			type: 'text',
			prefix: prefix,
			message: message,
			params: ['ERROR']
		)
	end

	def log_trade(type, btc)
		btc = readable_num(btc)
		message = "#{pair} - #{btc}"

		log_universal(
			type: 'trade',
			prefix: type,
			message: message,
			params: [type, btc],
			push_text: false
		)
	end

	private

	def log_universal(type:, prefix:, message:, params:, push_text: true)
		text_object = make_text(message, prefix)

		p text_object[:console]

		params.push(text_object[:database]) if push_text

		@db.log(type, params)
	end

	def make_text(message, prefix)
		if message.is_a? Exception
			error = message
			text = text_with_prefix(error.message, prefix)
			database = "#{text} --- #{error.backtrace.inspect}"
			console = text_with_date(text)
		else
			database = text_with_prefix(message, prefix)
			console = text_with_date(database)
		end

		{
			console: console,
			database: database
		}
	end

	def text_with_date(text)
		"#{Time.now} >>> #{text}"
	end

	def text_with_prefix(text, prefix)
		"[#{prefix or 'Void'}] #{text}"
	end

end