class AddThumbnailToItems < ActiveRecord::Migration[8.1]
  def change
    add_column :items, :thumbnail, :binary
  end
end
