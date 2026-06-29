class AddAdminToItems < ActiveRecord::Migration[8.1]
  def change
    add_reference :items, :admin, foreign_key: { to_table: :users }, index: true
  end
end
