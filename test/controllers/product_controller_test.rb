require 'test_helper'

class ProductControllerTest < ActionDispatch::IntegrationTest
  test "returns products sorted by descending average rating" do
    get product_index_url

    product_one = Product.find_by!(name: 'Product One')
    product_two = Product.find_by!(name: 'Product Two')

    assert_response :success
    assert_equal(JSON.parse(@response.body), {
      "data" => [
        ProductSerializer.new(product_two).serialize.stringify_keys,
        ProductSerializer.new(product_one).serialize.stringify_keys,
      ],
    })
  end

  test "returns product serialized as JSON" do
    product = Product.first

    get product_url(product)

    assert_response :success
    assert_equal(JSON.parse(@response.body), {
      "data" => {
        "average_rating" => product.average_rating,
        "created_at" => product.created_at.iso8601,
        "description" => product.description,
        "id" => product.id,
        "name" => product.name,
        "updated_at" => product.updated_at.iso8601,
      },
    })
  end
end
