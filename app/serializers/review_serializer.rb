# == Schema Information
#
# Table name: reviews
#
#  id         :uuid             not null, primary key
#  author     :string           not null
#  body       :string
#  rating     :integer          not null
#  title      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  product_id :uuid             not null
#
# Indexes
#
#  index_reviews_on_product_id  (product_id)
#  index_reviews_on_rating      (rating)
#

# Why have an explicit serializer when you can just use `.to_json`?
#
# The reason I prefer this approach is because it gives us complete and
# explicit control over the structure of our responses. It's simple enough
# that users can read and understand the code in seconds and it allows us
# to do things like include or exclude certain keys.
#
# By way of example, one common pattern I've come across is models having
# both an auto-incrementing ID and a UUID field named "uuid" or "token" or
# something like that. In this case, we don't want the auto-incrementing ID
# to be public for security-by-obscurity reasons. We'd rather use the UUID as
# the public unique identifier.
#
# With this approach to serialization, we simply do not include the `id` column
# in the output of the `serialize` method. This prevents us from having to
# write code like this:
#
#     product = Product.first
#     product.attributes.except("id").to_json
#
# Additionally, it helps ensure that serialization of `Review` objects is
# consistent across the codebase.
class ReviewSerializer
  attr_reader :review

  def initialize(review)
    @review = review
  end

  def serialize
    {
      author: review.author,
      created_at: review.created_at.iso8601,
      body: review.body,
      id: review.id,
      product_id: review.product_id,
      rating: review.rating,
      title: review.title,
      updated_at: review.updated_at.iso8601,
    }
  end
end
