class Api::V1::ProductsController < Api::V1::BaseController
	def show
		@product = Product.find(params[:id])
	end

	def create
		def keyword_to_urls(keywords)
			orgin_url = "https://s.2.taobao.com/list/list.htm?ist=0&q="
			urls = []

			for word in keywords
				# urlencode关键词
				word.gsub!(/\s/, "+")
				encoded_word = word.encode('gb2312', 'utf-8')
				word = URI.escape(encoded_word)
				url = "https://s.2.taobao.com/list/list.htm?ist=0&q=" + word

				# 配置爬取的地址数组（page=?）
				page_source = open(url, &:read).encode("UTF-8")
				page = page_source.scan(%r|共(.+?)页|)[0][0].to_i

				for i in 1..page
					urls.push "#{url}&page=#{i}"
				end
			end

			urls
		end

		# 创建product实例
		@product = Product.create(
			name: params[:name],
			keywords: params[:keywords],
			upper_p: params[:upper_p],
			lower_p: params[:lower_p],
			alarm_p: params[:alarm_p],
			filter: params[:filter])
		@items = []

		#curl -i -X POST -d "name=画框爱丽丝1&keywords=画框爱丽丝,wonder gallery&lower_p=1000&upper_p=2500&filter=山,他人,无效&alarm_p=1800" http://localhost:3000/api/v1/products.json
		#Product.new(name=画框爱丽丝&keywords=画框爱丽丝,wonder gallery&lower_p=1000&upper_p=2500&filter=山,他人,无效&alarm_p:1800

		def start_crawl
			keywords = @product.keywords.split(',')
			urls = keyword_to_urls(keywords)

			Anemone.crawl(urls, {:depth_limit => 0, :read_timeout => 10}) do |anemone|
				anemone.on_every_page do |page|
					parse(page)
				end
			end

			# 处理record_ids中的数据变动
			proc_items
		end

		def parse(page)
			doc = Nokogiri::HTML(page.body, nil, 'gbk')
			doc.encoding = "UTF-8"	

			# 待解析的xpath整体，数组形式
			item_list = doc.xpath("//div[@class=\"item-info\"]")

			# 拆分元素，并存入新的Item实例
			item_list.each do |item|
				p new_item = Item.new(
					id: item.xpath("h4/a").attribute("href").text.scan(%r|id=(\d+)|)[0][0],
					title: item.xpath("h4/a").text,
					desc: item.xpath("div[3]").text,
					price: item.xpath("div[2]/span/em").text.to_i,
					pic_url: "https:" + item.xpath("div[1]/a/img").attribute("src").text)

				if add_flag(new_item)
					@items.push(new_item)
				end
			end
		end

		def add_flag(new_item)
			# 过滤词
			filter = @product.filter.split(',')
			for word in filter
				return false if (new_item.title.downcase[word] || new_item.desc[word])
			end
				
			# 检查item是否重复
			for item in @items
				return false if (new_item.id == item.id)
			end

			# 根据价格阈值进行过滤
			if (new_item.price > @product.upper_p || new_item.price < @product.lower_p) && @product.upper_p != 0
				return false
			end

			return true
		end

		# 处理record_ids中的数据变动
		def proc_items
			# 抓到新数据时，处理数据
			if !@items.empty?
				record_ids_new = []

				@items.each do |item|
					record_ids_new<<item.id

					# 警报商品邮件发送
					# if item.price <= @alarm_p
					# 	NotifMail.send(@name, "alarm", item)
					# end
				end

				@product.record_ids = record_ids_new.join(',')
				@product.save
			end
		end

		start_crawl
	end
end

class Item
	def initialize(id:"", title:"", price:0, url:"", desc:"", pic_url:"")
		@id, @title, @price, @url, @desc, @pic_url = id, title, price, url, desc, pic_url
	end

	attr_accessor :id, :title, :price, :url, :desc, :pic_url
end
