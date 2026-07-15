class CreateItemReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :item_reviews do |t|
      t.references :item, null: false, foreign_key: true, index: { unique: true }
      t.datetime :last_checked_at

      t.timestamps
    end
  end
end
