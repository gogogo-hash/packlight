class Item < ApplicationRecord
  belongs_to :admin, class_name: "User", optional: true
  has_many :photos, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :subscriptions, as: :subscribable, dependent: :destroy

  validates :status, inclusion: { in: %w[pending processed error] }, allow_nil: true
end
