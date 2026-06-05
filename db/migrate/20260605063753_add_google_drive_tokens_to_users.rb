class AddGoogleDriveTokensToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :google_drive_token, :string
    add_column :users, :google_drive_refresh_token, :string
  end
end
