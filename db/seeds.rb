# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Review.delete_all
Product.delete_all

products = []

5.times do |i|
  products << Product.create!(name: "Product #{i}", description: "Product description #{i}")
end

10.times do |i|
  products.each_with_index do |product, j|
    Review.create!(
      author: "author-#{i}",
      body: "Body text",
      product_id: product.id,
      rating: j + 1,
      title: "Review title",
    )
  end
end

Product.all.each do |product|
  UpdateAverageProductRating.new.perform(product.id)
end
