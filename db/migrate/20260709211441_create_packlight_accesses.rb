class CreatePacklightAccesses < ActiveRecord::Migration[8.1]
  def change
    create_table :packlight_accesses do |t|
      t.string :email, null: false
      t.string :packlight_id, null: false

      t.timestamps
    end

    add_index :packlight_accesses, [ :email, :packlight_id ], unique: true
  end
end
