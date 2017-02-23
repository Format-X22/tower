def delisted?
	delisted = false

	stock_news.each do |post|
		if delisting_condition?(post)
			delisted = true
		end
	end

	delisted
end

def listed?
	new_coin = false

	stock_news.each do |post|
		if listed_condition?(post)
			new_coin = true
		end
	end

	new_coin
end

def reset_calm_type
	meta.calm_type = 'normal'
end

def set_listed_calm_type
	meta.calm_type = 'add_coin'
end

def store_listed_calm_time
	meta.calm = now + calm.add_coin
end

def delisting_condition?(post)
	delisting_words?(post.text) and pair_name?(post.text)
end

def listed_condition?(post)
	in_add_state = meta.state == 'listed'
	in_text = add_coin_words?(post.text)
	in_news_offset = now - profile.new_coin_add_wait_offset < post.date

	in_add_state or (in_text and in_news_offset)
end


def delisting_words?(text)
	text.match('delist')
end

def pair_name?(text)
	/\s#{@pair}|,#{@pair}|:#{@pair}/.match(text)
end

def add_coin_words?(text)
	text.match('added') and text.match('/BTC')
end

def stock_news
	#
end

def remove_order(id)
	#
end