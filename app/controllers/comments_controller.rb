class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item

  def create
    @comment = @item.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      # NotifySubscribersJob disabled for beta — not using subscriber email notifications yet.
      redirect_to @item, notice: "Comment created successfully."
    else
      redirect_to @item, alert: "Error creating comment."
    end
  end

  private

  def set_item
    @item = Item.find(params[:item_id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
