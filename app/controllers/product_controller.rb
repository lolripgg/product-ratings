class ProductController < ApplicationController
  def index
    products = Product.order(average_rating: :desc).all

    render json: {
      data: products.map do |product|
        ProductSerializer.new(product).serialize
      end,
    }, status: 200
  end

  def show
    product = Product.find(params[:id])

    render json: {
      data: ProductSerializer.new(product).serialize,
    }, status: 200
  end
end
