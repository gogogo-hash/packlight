class AddPacklightPublicToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :packlight_public, :boolean, default: false, null: false
    add_index :users, :packlight_public
  end
end
