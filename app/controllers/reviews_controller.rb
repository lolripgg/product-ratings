class ReviewsController < ApplicationController
  REVIEW_ORDER_CREATED_AT_ASCENDING = 'created_at'
  REVIEW_ORDER_CREATED_AT_DESCENDING = '-created_at'
  REVIEW_ORDER_RATING_ASCENDING = 'rating'
  REVIEW_ORDER_RATING_DESCENDING = '-rating'

  DEFAULT_REVIEW_ORDER = REVIEW_ORDER_CREATED_AT_DESCENDING

  REVIEW_ORDERS = [
    REVIEW_ORDER_CREATED_AT_ASCENDING,
    REVIEW_ORDER_CREATED_AT_DESCENDING,
    REVIEW_ORDER_RATING_ASCENDING,
    REVIEW_ORDER_RATING_DESCENDING,
  ]

  # I've kept this here for simplicity, but ultimately this would be useful
  # for most, if not all, endpoints. In that case, we'd probably move this
  # error and the `rescue_from` block below to ApplicationController.
  class InvalidRequestField < StandardError
    attr_reader :field, :message

    def initialize(message:, field: nil)
      super(message)

      @message = message
      @field = field
    end
  end

  rescue_from InvalidRequestField do |exception|
    # The goal here is to provide enough useful information to the consumer of
    # our API that they know what to do next.
    #
    # The `code` field communicates the specific error that occured. In this
    # case, it's that a field in the request was invalid.
    #
    # The `type` field acts as a way to group different error codes together.
    # For example, another error code could be `INVALID_REQUEST_PARAMETER` and
    # that would also fall under the `INVALID_REQUEST` type.
    #
    # The `field` field tells the caller which field triggered this error.
    #
    # The `message` field is a human-readable description of the error.
    #
    # There are other ways to improve this structure. For one, we should return
    # an `errors` key as an array of error objects instead of a single `error`
    # key. That way we can return as many errors as we can at the same time.
    # This is especially useful when return request validation errors where
    # there can frequently be more than one error. Another useful field to add
    # is a `detail` field whose value is a link to additional documentation
    # about this error.
    render json: {
      error: {
        code: 'INVALID_REQUEST_FIELD',
        field: exception.field,
        message: exception.message,
        type: 'INVALID_REQUEST',
      },
    }, status: 400
  end

  def create
    parameters = validate_create_request!(create_params)

    review = Review.create!(
      product_id: parameters[:meta][:product_id],
      **parameters[:data],
    )

    # See the comment in `UpdateAverageProductRating` for an explanation of why
    # this is a job instead of being updating in the request-response cycle.
    UpdateAverageProductRating.perform_async(parameters[:meta][:product_id])

    render json: {
      # See the comment in `ReviewSerializer` for an explanation of why I
      # prefer explicit serializers over relying on `.to_json`.
      data: ReviewSerializer.new(review).serialize,
    }, status: 201
  end


  def index
    parameters = validate_index_request!(index_params)

    reviews = Review
      .where(product_id: parameters[:meta][:product_id])
      .order(**parameters[:meta][:order]).all

    render json: {
      data: reviews.map do |review|
        # See the comment in `ReviewSerializer` for an explanation of why I
        # prefer explicit serializers over relying on `.to_json`.
        ReviewSerializer.new(review).serialize
      end,
      # The `meta` key is a convenience features that just echos the values
      # provided in the request. You can add additional things here such as
      # `after` and `limit` for pagination, `idempotence_token` to echo the
      # idempotence token that was provided, a `request_id` for help with
      # debugging, etc.
      meta: {
        order: index_params.fetch(:meta, {})[:order] || DEFAULT_REVIEW_ORDER,
      },
    }, status: 200
  end

  private

  def create_params
    params.permit(:product_id, data: [:author, :body, :rating, :title])
  end

  def index_params
    params.permit(:product_id, meta: [:order])
  end

  def validate_create_request!(params)
    validate_product_id_parameter!(params)

    if params[:data].nil? || !params[:data].is_a?(ActionController::Parameters)
      raise InvalidRequestField.new(
        field: 'data',
        message: 'The "data" field must be a valid JSON object.',
      )
    end

    author = params[:data][:author]
    body = params[:data][:body]
    rating = params[:data][:rating]
    title = params[:data][:title]

    if author.nil? || !author.is_a?(String) || author.blank?
      raise InvalidRequestField.new(
        field: 'data.author',
        message: 'The "data.author" field must be a non-empty string.',
      )
    end

    if body.present? && !body.is_a?(String)
      raise InvalidRequestField.new(
        field: 'data.body',
        message: 'The "data.body" field must be "null" or a string.',
      )
    end

    if rating.nil? || !rating.is_a?(Integer) || rating < 1 || rating > 5
      raise InvalidRequestField.new(
        field: 'data.rating',
        message: 'The "data.rating" field must be an integer between 1 and 5, inclusive.',
      )
    end

    if title.nil? || !title.is_a?(String) || title.blank?
      raise InvalidRequestField.new(
        field: 'data.title',
        message: 'The "data.title" field must be a non-empty string.',
      )
    end

    {
      data: {
        author: author,
        body: body,
        rating: rating,
        title: title,
      },
      meta: {
        product_id: params[:product_id],
      },
    }
  end

  def validate_index_request!(params)
    validate_product_id_parameter!(params)

    if params[:meta].present? && !params[:meta].is_a?(ActionController::Parameters)
      raise InvalidRequestField.new(
        field: 'meta',
        message: 'The "meta" field must be "null" or a valid JSON object.',
      )
    end

    meta = params[:meta].to_h || {}
    meta[:order] ||= DEFAULT_REVIEW_ORDER

    order = nil

    if meta[:order] == REVIEW_ORDER_CREATED_AT_ASCENDING
      order = { created_at: :asc }
    elsif meta[:order] == REVIEW_ORDER_CREATED_AT_DESCENDING
      order = { created_at: :desc }
    elsif meta[:order] == REVIEW_ORDER_RATING_ASCENDING
      order = { rating: :asc, created_at: :desc }
    elsif meta[:order] == REVIEW_ORDER_RATING_DESCENDING
      order = { rating: :desc, created_at: :desc }
    end

    if order.nil?
      orders = REVIEW_ORDERS.map do |order|
        "\"#{order}\""
      end.join(', ')

      raise InvalidRequestField.new(
        field: 'meta.order',
        message: "The \"meta.order\" field must be \"null\" or one of #{orders}.",
      )
    end

    {
      meta: {
        order: order,
        product_id: params[:product_id],
      },
    }
  end

  def validate_product_id_parameter!(params)
    if params[:product_id].nil? || !params[:product_id].is_a?(String)
      # This should never happen because `product_id` is provided automatically
      # by Rails' routing system. In production we'd want to throw an alert if
      # this happened because it violates an assumption we have about how Rails
      # works.
      raise InvalidRequestField.new(
        field: 'product_id',
        message: 'The "product_id" field must be a non-empty string.',
      )
    end
  end
end
