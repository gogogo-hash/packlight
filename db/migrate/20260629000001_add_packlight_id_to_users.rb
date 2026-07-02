class AddPacklightIdToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :packlight_id, :string
    add_index :users, :packlight_id, unique: true
  end
end
