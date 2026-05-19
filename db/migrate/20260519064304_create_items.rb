class CreateItems < ActiveRecord::Migration[8.1]
  def change
    create_table :items do |t|
      t.string :name
      t.text :description
      t.decimal :price
      t.string :file_folder_path
      t.string :status
      t.datetime :last_scanned_at

      t.timestamps
    end
  end
end
