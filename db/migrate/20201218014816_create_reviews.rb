class CreateReviews < ActiveRecord::Migration[6.0]
  def change
    create_table :reviews, id: :uuid do |t|
      t.string :author, null: false
      t.string :body
      t.uuid :product_id, null: false
      t.integer :rating, limit: 2, null: false # +/- 32,768
      t.string :title, null: false

      t.timestamps

      t.index :product_id
      t.index :rating
    end
  end
end
