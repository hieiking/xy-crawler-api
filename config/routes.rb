Rails.application.routes.draw do
	namespace :api do
	  namespace :v1 do
	    resources :products, only: [:index, :create, :show, :update, :destroy]
	    # 原文有 microposts, 我们现在把它注释掉
	    # resources :microposts, only: [:index, :create, :show, :update, :destroy]
	  end
	end
end
