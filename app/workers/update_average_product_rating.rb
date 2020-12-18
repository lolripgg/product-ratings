class UpdateAverageProductRating < ApplicationJob
  def perform(product_id)
    product = Product.find(product_id)
    product.average_rating = Review.where(product_id: product.id).average(:rating).to_f
    product.save!
  end
end
