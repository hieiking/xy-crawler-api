class Api::V1::BaseController < ApplicationController
	# disable the CSRF token
  protect_from_forgery with: :null_session

  # disable cookies (no set-cookies header in response)
  before_action :destroy_session

  # disable the CSRF token
  skip_before_action :verify_authenticity_token

  def destroy_session
    request.session_options[:skip] = true
  end

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
	
end
