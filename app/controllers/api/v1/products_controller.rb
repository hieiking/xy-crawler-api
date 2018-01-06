class Api::V1::ProductsController < Api::V1::BaseController
	def show
		@product = Product.find(params[:id])
		@items = []

		start_crawl("show")
	end

	def create
		# 创建product实例
		@product = Product.create(name: params[:name],
															keywords: params[:keywords],
															upper_p: params[:upper_p],
															lower_p: params[:lower_p],
															alarm_p: params[:alarm_p],
															filter: params[:filter])
		@items = []
	
		start_crawl("create")
	end

	def update
		@product = Product.find(params[:id])
		@product.update_attributes(name: params[:name],
															keywords: params[:keywords],
															upper_p: params[:upper_p],
															lower_p: params[:lower_p],
															alarm_p: params[:alarm_p],
															filter: params[:filter],
															except_ids: params[:except_ids])
		@items = []

		start_crawl("show")
	end

	def destroy
	end

	# --------------- crawler helper ------------------------------------
	def start_crawl(type)
		keywords = @product.keywords.split(',')
		urls = keyword_to_urls(keywords)

		Anemone.crawl(urls, {:depth_limit => 0, :read_timeout => 10}) do |anemone|
			anemone.on_every_page do |page|
				parse(page)
			end
		end

		proc_items(type)
	end

	def proc_items(type)
		record_ids_new = []
		
		for item in @items
			puts "─=≡Σ(((つ•̀ω•́)つ有低价商品 #{@product.name} #{item.item_id}" if item.price <= @product.alarm_p #mail

			case type
			when "create" then # 创建新的Product实例
				item.product = @product
				item.save
				record_ids_new<<item.item_id

			when "show" then
				if Item.find_by(item_id:item.item_id)
					# item ID是否已经存在。已存在Item，检查降价
					old_item = Item.find_by(item_id:item.item_id)

					puts "###有降价商品 #{item}" if old_item.price > item.price #mail
					old_item.title, old_item.desc, old_item.price, old_item.pic_url = item.title, item.desc, item.price, item.pic_url # 更新项目
					old_item.save
					record_ids_new<<item.item_id
				else 
					# 不存在，创建新Item实例
					item.product = @product
					item.save
					record_ids_new<<item.item_id
					puts "###有新商品 #{@product.name} #{item.item_id}" #mail
				end
			end
		end

		# 检查已售出Item
		if !@product.record_ids.empty?
			record_ids = @product.record_ids.split(',') 
			sold_ids = record_ids - (record_ids_new & record_ids)

			# 删除售出商品和邮件
			if !sold_ids.empty?
				for id in sold_ids
					sold_item = Item.find_by(item_id:id)
					puts "商品已经出售 #{sold_item}" 
					sold_item.destroy
				end
			end
    end

    puts "【record id】 #{record_ids_new}"
    @product.record_ids = record_ids_new.join(',') if !record_ids_new.empty?
		@product.save
	end

	# 分析页面，将商品放入@items属性
	def parse(page)
		doc = Nokogiri::HTML(page.body, nil, 'gbk')
		doc.encoding = "UTF-8"	

		# 待解析的xpath整体，数组形式
		item_list = doc.xpath("//div[@class=\"item-info\"]")

		# 拆分元素，并存入新的Item实例
		item_list.each do |item|
			new_item = Item.new(item_id:item.xpath("h4/a").attribute("href").text.scan(%r|id=(\d+)|)[0][0],
													title:item.xpath("h4/a").text,
													desc:item.xpath("div[3]").text,
													price:item.xpath("div[2]/span/em").text.to_i,
													pic_url:"https:" + item.xpath("div[1]/a/img").attribute("src").text)
			@items<<new_item if add_flag(new_item)
		end
	end

	# 处理各项指标
	def add_flag(new_item)
		# 过滤词
		filter = @product.filter.split(',')
		for word in filter
			return false if (new_item.title.downcase[word] || new_item.desc[word])
		end

		# 除外item列表
		except_ids = @product.except_ids.split(',')
		for id in except_ids			
			return false if id == new_item.item_id
		end
				
		# 检查item是否重复
		for item in @items
			return false if (new_item.item_id == item.item_id)
		end

		# 根据价格阈值进行过滤
		if (new_item.price > @product.upper_p || new_item.price < @product.lower_p) && @product.upper_p != 0
			return false
		end

		return true
	end
end

