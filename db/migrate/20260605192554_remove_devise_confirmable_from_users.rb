class RemoveDeviseConfirmableFromUsers < ActiveRecord::Migration[8.1]
  def change
    remove_columns :users,
                   :confirmation_token,
                   :confirmed_at,
                   :confirmation_sent_at,
                   :unconfirmed_email,
                   type: :string
  end
end
