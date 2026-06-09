class AddGoogleDriveTokenExpiresAtToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :google_drive_token_expires_at, :integer
  end
end
