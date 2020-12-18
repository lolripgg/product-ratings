class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :products, id: :uuid  do |t|
      t.string :name, null: false
      t.string :description
      t.float :average_rating, null: true

      t.timestamps

      t.index :average_rating
      t.index :name, unique: true
    end
  end
end
