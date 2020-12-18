require 'test_helper'

class ReviewsControllerTest < ActionDispatch::IntegrationTest
  test "#create returns the expected response" do
    product = Product.first

    post product_reviews_url(product), as: :json, params: {
      data: {
        author: 'James Brewer',
        body: nil,
        rating: 5,
        title: 'Rails is a great framework.',
      },
    }

    review = Review.order(:created_at).last

    assert_response :created
    assert_equal(JSON.parse(@response.body), {
      "data" => ReviewSerializer.new(review).serialize.stringify_keys,
    })
  end

  test "#create validates author" do
    product = Product.first

    post product_reviews_url(product), as: :json, params: {
      data: {
        author: nil,
        body: nil,
        rating: 5,
        title: 'Rails is a great framework.',
      },
    }

    assert_response :bad_request
    assert_equal(JSON.parse(@response.body), {
      "error" => {
        "code" => "INVALID_REQUEST_FIELD",
        "field" => "data.author",
        "message" => 'The "data.author" field must be a non-empty string.',
        "type" => "INVALID_REQUEST",
      },
    })
  end

  test "#create validates body" do
    product = Product.first

    post product_reviews_url(product), as: :json, params: {
      data: {
        author: 'James Brewer',
        body: 1,
        rating: 5,
        title: 'Rails is a great framework.',
      },
    }

    assert_response :bad_request
    assert_equal(JSON.parse(@response.body), {
      "error" => {
        "code" => "INVALID_REQUEST_FIELD",
        "field" => "data.body",
        "message" => 'The "data.body" field must be "null" or a string.',
        "type" => "INVALID_REQUEST",
      },
    })
  end

  test "#create validates data" do
    product = Product.first

    post product_reviews_url(product), as: :json, params: {
      data: nil,
    }

    assert_response :bad_request
    assert_equal(JSON.parse(@response.body), {
      "error" => {
        "code" => "INVALID_REQUEST_FIELD",
        "field" => "data",
        "message" => 'The "data" field must be a valid JSON object.',
        "type" => "INVALID_REQUEST",
      },
    })
  end

  test "#create validates rating" do
    product = Product.first

    post product_reviews_url(product), as: :json, params: {
      data: {
        author: 'James Brewer',
        body: nil,
        rating: nil,
        title: 'Rails is a great framework.',
      },
    }

    assert_response :bad_request
    assert_equal(JSON.parse(@response.body), {
      "error" => {
        "code" => "INVALID_REQUEST_FIELD",
        "field" => "data.rating",
        "message" => 'The "data.rating" field must be an integer between 1 and 5, inclusive.',
        "type" => "INVALID_REQUEST",
      },
    })
  end

  test "#create validates title" do
    product = Product.first

    post product_reviews_url(product), as: :json, params: {
      data: {
        author: 'James Brewer',
        body: nil,
        rating: 5,
        title: nil,
      },
    }

    assert_response :bad_request
    assert_equal(JSON.parse(@response.body), {
      "error" => {
        "code" => "INVALID_REQUEST_FIELD",
        "field" => "data.title",
        "message" => 'The "data.title" field must be a non-empty string.',
        "type" => "INVALID_REQUEST",
      },
    })
  end

  test "#index returns the expected response" do
    product = Product.first

    get product_reviews_url(product)

    reviews = Review.where(product_id: product.id).order(created_at: :desc)

    assert_response :success
    assert_equal(JSON.parse(@response.body), {
      "data" => reviews.map do |review|
        ReviewSerializer.new(review).serialize.stringify_keys
      end,
      "meta" => {
        "order" => "-created_at",
      },
    })
  end

  test "#index supports sorting by ascending created timestamp" do
    product = Product.first

    get product_reviews_url(product), params: {
      meta: {
        order: "created_at",
      },
    }

    reviews = Review.where(product_id: product.id).order(created_at: :asc)

    assert_response :success
    assert_equal(JSON.parse(@response.body), {
      "data" => reviews.map do |review|
        ReviewSerializer.new(review).serialize.stringify_keys
      end,
      "meta" => {
        "order" => "created_at",
      },
    })
  end

  test "#index supports sorting by ascending rating" do
    product = Product.first

    get product_reviews_url(product), params: {
      meta: {
        order: "rating",
      },
    }

    reviews = Review.where(product_id: product.id).order(rating: :asc)

    assert_response :success
    assert_equal(JSON.parse(@response.body), {
      "data" => reviews.map do |review|
        ReviewSerializer.new(review).serialize.stringify_keys
      end,
      "meta" => {
        "order" => "rating",
      },
    })
  end

  test "#index supports sorting by descending created timestamp" do
    product = Product.first

    get product_reviews_url(product), params: {
      meta: {
        order: "-created_at",
      },
    }

    reviews = Review.where(product_id: product.id).order(created_at: :desc)

    assert_response :success
    assert_equal(JSON.parse(@response.body), {
      "data" => reviews.map do |review|
        ReviewSerializer.new(review).serialize.stringify_keys
      end,
      "meta" => {
        "order" => "-created_at",
      },
    })
  end

  test "#index supports sorting by descending rating" do
    product = Product.first

    get product_reviews_url(product), params: {
      meta: {
        order: "-rating",
      },
    }

    reviews = Review.where(product_id: product.id).order(rating: :desc)

    assert_response :success
    assert_equal(JSON.parse(@response.body), {
      "data" => reviews.map do |review|
        ReviewSerializer.new(review).serialize.stringify_keys
      end,
      "meta" => {
        "order" => "-rating",
      },
    })
  end

  test "#index validates order" do
    product = Product.first

    get product_reviews_url(product), params: {
      meta: {
        order: 'EXAMPLE_INVALID_ORDER',
      },
    }

    assert_response :bad_request
    assert_equal(JSON.parse(@response.body), {
      "error" => {
        "code" => "INVALID_REQUEST_FIELD",
        "field" => "meta.order",
        "message" => 'The "meta.order" field must be "null" or one of "created_at", "-created_at", "rating", "-rating".',
        "type" => "INVALID_REQUEST",
      },
    })
  end
end
