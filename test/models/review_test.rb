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
require 'test_helper'

class ReviewTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
