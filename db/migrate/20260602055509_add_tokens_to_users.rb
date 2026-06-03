class AddTokensToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :google_token, :string
    add_column :users, :google_refresh_token, :string
    add_column :users, :google_token_expires_at, :integer
  end
end
