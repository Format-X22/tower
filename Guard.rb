require 'twitter'
require_relative 'Utils'

class Guard

	include Utils

	def initialize(database, polo)
		@database = database
		@polo = polo
		@twitter = Twitter::REST::Client.new do |config|
			config.consumer_key        = 'Ttq7dDhLdXbXBrfvDz6DwSL36'
			config.consumer_secret     = 'nQ6G5RV1vOtsDZq0es2sqvbaHKE3IwiTwbz8u54cg2zpbiC3mY'
			config.access_token        = '813051612423946240-yxaKsK2py0Za8whvAfyQUIRaS6fIXhV'
			config.access_token_secret = 'jeAGtOnRAndK3BQaPrkM1EFoRPxmq7mG1l29xeTNkiPgC'
		end
	end

	def check_de_listing
		pairs = @database.pairs
		money = @polo.money
		status = 'ok'

		@twitter.user_timeline('poloniex').each do |tweet|
			if tweet.text.match('delist')
				de_listed = parse_de_listing_pairs(tweet.text, pairs, money)

				if de_listed.length > 0
					panic_sell(de_listed, money)
					status = 'de_listing'
				end
			end
		end

		status
	end

	private

	def parse_de_listing_pairs(text, pairs, money)
		de_listed = []
		all_orders = @polo.orders

		pairs.each do |pair|
			if text.match(pair)
				if num(money[pair]) > 0 or pair_orders(pair, all_orders)
					de_listed.push(pair)
				end
			end
		end

		de_listed
	end

	def panic_sell(pairs, money)
		all_orders = @polo.orders

		pairs.each do |pair|
			begin
				panic_sell_for(
					pair,
					num(money[pair]),
					pair_orders(pair, all_orders)
				)
			rescue Exception => exception
				log_exception(exception, 'Panic sell error - ')
			end
		end
	end

	def panic_sell_for(pair, pair_money, orders)
		@polo.pair = pair
		@database.pair = pair

		if orders.length > 0
			orders.each do |order|
				rate = first_in_glass('bids')
				amount = num(order['amount'])

				begin
					@polo.replace(order['orderNumber'], rate, amount)
				rescue Exception => exception
					log_exception(exception, 'Panic sell error - ')
				end
			end
		else
			make_panic_sell_train(pair_money).each do |wagon|
				@polo.sell(wagon[0], wagon[1])
			end

			@database.log_trade('PANIC SELL', 0)
		end
	end

	def make_panic_sell_train(total_amount)
		glass = @polo.glass['bids']
		train = []
		glass.pop

		while total_amount > 0
			order = glass.pop
			rate = num(order[0])
			amount = num(order[1])

			if amount > total_amount
				train.push([rate, total_amount])
			else
				train.push([rate, amount])
			end

			total_amount -= amount
		end

		train
	end

end