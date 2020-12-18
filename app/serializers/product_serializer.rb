# == Schema Information
#
# Table name: products
#
#  id             :uuid             not null, primary key
#  average_rating :float
#  description    :string
#  name           :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_products_on_average_rating  (average_rating)
#  index_products_on_name            (name) UNIQUE
#
class ProductSerializer
  attr_reader :product

  def initialize(product)
    @product = product
  end

  def serialize
    {
      average_rating: product.average_rating,
      created_at: product.created_at.iso8601,
      description: product.description,
      id: product.id,
      name: product.name,
      updated_at: product.updated_at.iso8601,
    }
  end
end
