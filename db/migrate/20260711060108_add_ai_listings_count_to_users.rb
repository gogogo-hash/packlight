class AddAiListingsCountToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :ai_listings_count, :integer, default: 0, null: false
  end
end
