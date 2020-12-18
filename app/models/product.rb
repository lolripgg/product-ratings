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
class Product < ApplicationRecord
end
