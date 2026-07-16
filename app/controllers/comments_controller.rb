class CommentsController < ApplicationController
  include PacklightAuthorization

  before_action :authenticate_user!
  before_action :set_packlight_admin
  before_action :authorize_packlight_viewer!
  before_action :set_item

  def create
    @comment = @item.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      # NotifySubscribersJob disabled for beta — not using subscriber email notifications yet.
      redirect_to packlight_item_path(packlight_id: @admin.packlight_id, id: @item.id), notice: "Comment created successfully."
    else
      redirect_to packlight_item_path(packlight_id: @admin.packlight_id, id: @item.id), alert: "Error creating comment."
    end
  end

  private

  def set_item
    @item = @admin.items.find(params[:item_id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
