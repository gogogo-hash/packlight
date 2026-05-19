class ItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item, only: [:show]

  def index
    @items = Item.where(status: "processed").order(created_at: :desc)
  end

  def show
    @comments = @item.comments.includes(:user).order(created_at: :desc)
    @comment = Comment.new
    @subscribed = current_user.subscriptions.exists?(subscribable: @item)
  end

  private

  def set_item
    @item = Item.find(params[:id])
  end
end
