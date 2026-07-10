class AddUniqueIndexToSubscriptions < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      DELETE FROM subscriptions a
      USING subscriptions b
      WHERE a.id > b.id
        AND a.user_id = b.user_id
        AND a.subscribable_type = b.subscribable_type
        AND a.subscribable_id = b.subscribable_id
    SQL

    add_index :subscriptions, [ :user_id, :subscribable_type, :subscribable_id ],
              unique: true, name: "index_subscriptions_on_user_and_subscribable"
  end

  def down
    remove_index :subscriptions, name: "index_subscriptions_on_user_and_subscribable"
  end
end
