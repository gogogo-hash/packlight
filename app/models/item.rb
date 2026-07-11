class Item < ApplicationRecord
  belongs_to :admin, class_name: "User", optional: true
  has_many :photos, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :subscriptions, as: :subscribable, dependent: :destroy
  has_one :item_review, dependent: :destroy

  validates :status, inclusion: { in: %w[pending processed error sold] }, allow_nil: true

  def last_checked_at
    item_review&.last_checked_at
  end

  def new_activity?
    last_comment_at = comments.map(&:created_at).max
    return false if last_comment_at.nil?

    last_checked_at.nil? || last_comment_at > last_checked_at
  end

  def mark_reviewed!
    review = item_review || build_item_review
    review.update!(last_checked_at: Time.current)
  end
end
