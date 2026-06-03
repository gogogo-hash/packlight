class AddTargetGoogleFolderIdToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :target_google_folder_id, :string
  end
end
