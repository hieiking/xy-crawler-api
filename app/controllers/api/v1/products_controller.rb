class Api::V1::ProductsController < Api::V1::BaseController
	@product = Product.find(params[:id])
end
