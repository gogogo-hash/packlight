class NotifySubscribersJob < ApplicationJob
  queue_as :default

  def perform(comment_id)
    comment = Comment.find(comment_id)
    item = comment.item

    # Find all users subscribed to this item
    subscribers = item.subscriptions
      .where(subscribable_type: "Item")
      .includes(:user)
      .map(&:user)
      .uniq

    subscribers.each do |subscriber|
      CommentMailer.new_comment(comment, subscriber).deliver_later
    end
  end
end
