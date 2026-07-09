class PacklightPagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_admin
  before_action :authorize_viewer!

  def show
    @items = @admin.items.where(status: "processed").order(created_at: :desc)
  end

  def item
    @item = @admin.items.find(params[:id])
    @comments = @item.comments.includes(:user).order(created_at: :desc)
    @comment = Comment.new
  end

  private

  def set_admin
    @admin = User.find_by!(packlight_id: params[:packlight_id])
  rescue ActiveRecord::RecordNotFound
    render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
  end

  def authorize_viewer!
    return if current_user == @admin
    return if PacklightAccess.exists?(email: current_user.email.to_s.strip.downcase, packlight_id: @admin.packlight_id)

    render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
  end
end
