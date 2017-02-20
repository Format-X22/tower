require_relative '../db/Abstract'
require_relative './Format'

class Logger
	extend Abstract

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
		if message.is_a? Exception
			text = make_text_with_trace(message)
			short_text = make_text(message.message, prefix)

			p make_text_with_date(short_text)
		else
			text = make_text(message, prefix)

			p make_text_with_date(text)
		end

		params.push(text) if push_text

		exec(query, params)
	end

	def make_text(text, prefix)
		"[#{prefix or 'Void'}] #{text}"
	end

	def make_text_with_date(text)
		"#{Time.now} >>> #{text}"
	end

	def make_text_with_trace(error)
		text = make_text(error.message, nil)

		"#{text} --- #{error.backtrace.inspect}"
	end
end