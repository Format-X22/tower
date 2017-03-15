# TODO Re
require_relative '_'

class Logger < Abstract

	def log(message, prefix = nil)
		log_universal(
			message: message,
			prefix: prefix,
			query: 'INSERT INTO log_text (text) VALUES ($1)',
			params: []
		)
	end

	def log_warn(message, prefix = nil)
		log_universal(
			message: message,
			prefix: prefix,
			query: 'INSERT INTO log_text (type, text) VALUES ($1, $2)',
			params: ['WARN']
		)
	end

	def log_error(message, prefix = nil)
		log_universal(
			message: message,
			prefix: prefix,
			query: 'INSERT INTO log_text (type, text) VALUES ($1, $2)',
			params: ['ERROR']
		)
	end

	def log_trade(pair, type, btc)
		btc = Format.readable_num(btc)
		message = "#{pair} - #{btc}"

		log_universal(
			message: message,
			prefix: type,
			query: 'INSERT INTO log_trade (type, pair, btc) VALUES ($1, $2, $3)',
			params: [type, pair, btc],
			push_text: false
		)
	end

	private

	def log_universal(message:, prefix:, query:, params:, push_text: true)
		text_object = make_text(message, prefix)

		p text_object[:console]

		params.push(text_object[:database]) if push_text

		exec(query, params)
	end

	def make_text(message, prefix)
		if message.is_a? Exception
			error = message
			text = make_text_with_prefix(error.message, prefix)
			database = "#{text} --- #{error.backtrace.inspect}"
			console = make_text_with_date(text)
		else
			database = make_text_with_prefix(message, prefix)
			console = make_text_with_date(database)
		end

		{
			console: console,
			database: database
		}
	end

	def make_text_with_date(text)
		"#{Time.now} >>> #{text}"
	end

	def make_text_with_prefix(text, prefix)
		"[#{prefix or 'Void'}] #{text}"
	end
end