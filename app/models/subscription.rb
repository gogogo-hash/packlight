class Subscription < ApplicationRecord
  belongs_to :subscribable, polymorphic: true
  belongs_to :user

  validates :user_id, uniqueness: { scope: [ :subscribable_type, :subscribable_id ] }
end
