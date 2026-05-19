class CreatePhotos < ActiveRecord::Migration[8.1]
  def change
    create_table :photos do |t|
      t.references :item, null: false, foreign_key: true
      t.string :file_name
      t.binary :image_data
      t.integer :order

      t.timestamps
    end
  end
end
