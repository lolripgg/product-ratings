class UpdateAverageProductRating < Worker
  # Why is this a job?
  #
  # Because the average rating being exactly right all the time isn't worth the
  # performance cost of the query used to calculate it. Averages are a good 
  # opportunity to settle for "close enough" accuracy.
  #
  # When the number of reviews for a product is small, the performance impact
  # is negligable, but as the number of reviews grows the calculation gets
  # slower and eventually leads to a noticable impact at some point. I haven't
  # benchmarked to find out what this point is.
  #
  # In this case I think it's better to be safe and make update the average
  # rating outside of the request-response cycle.
  #
  # There are some problems with this approach though:
  #
  # 1. When the number of reviews is low, it'll be obvious that the average
  #    rating didn't update immediately. This could negatively impact user
  #    experience.
  #
  # 2. As the number of new reviews grows, updating the average rating every
  #    time a review is created will also cause performance issues. There are
  #    ways around this, such as doing something like
  #
  #        UPDATE products
  #        SET products.average_rating = (
  #            SELECT AVG(rating)
  #            FROM reviews
  #            WHERE reviews.product_id = products.id
  #        )
  #
  #   but that has it's own trade-offs. Specifically, you need to have some
  #   type of scheduling that ensures you're not updating the same row
  #   multiple times and that every row is updating at least, for example,
  #   once a day.
  #
  #   TL;DR These problems are too complex to solve in this take-home
  #   assignment.

  def perform(product_id)
    product = Product.find(product_id)
    product.average_rating = Review.where(product_id: product.id).average(:rating).to_f.round(2)
    product.save!
  end
end
