class PacklightPagesController < ApplicationController
  include PacklightAuthorization

  before_action :authenticate_user!
  before_action :set_packlight_admin
  before_action :authorize_packlight_viewer!

  def show
    @items = @admin.items.where(status: "processed").order(created_at: :desc)
  end

  def item
    @item = @admin.items.find(params[:id])
    @comments = @item.comments.includes(:user).order(created_at: :desc)
    @comment = Comment.new
    @subscribed = @item.subscriptions.exists?(user_id: current_user.id)
  end
end
