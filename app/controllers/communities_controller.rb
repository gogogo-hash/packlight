class CommunitiesController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.where(admin: true).order(created_at: :asc)

    accessible_packlight_ids = PacklightAccess.where(email: current_user.email).pluck(:packlight_id)
    @recent_items = Item.includes(:admin)
                         .joins(:admin)
                         .where(users: { packlight_id: accessible_packlight_ids }, status: "processed")
                         .order(created_at: :desc)
                         .limit(10)
  end
end
