class Item < ApplicationRecord
  has_many :photos, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :subscriptions, as: :subscribable, dependent: :destroy

  validates :name, :description, :price, presence: true
  validates :status, inclusion: { in: %w(pending processed error) }, allow_nil: true
end
