class CommunitiesController < ApplicationController
  before_action :authenticate_user!

  def index
    accessible_packlight_ids = PacklightAccess.where(email: current_user.email).pluck(:packlight_id)

    @users = User.where(admin: true, packlight_id: accessible_packlight_ids).order(created_at: :asc)

    @recent_items = Item.includes(:admin)
                         .joins(:admin)
                         .where(users: { packlight_id: accessible_packlight_ids }, status: "processed")
                         .order(created_at: :desc)
                         .limit(10)

    if params[:q].present?
      @search_results = search_items(accessible_packlight_ids, params[:q])
    end
  end

  private

  def search_items(accessible_packlight_ids, query)
    scope = Item.includes(:admin)
                 .joins(:admin)
                 .where(users: { packlight_id: accessible_packlight_ids }, status: "processed")

    query.strip.split(/\s+/).each do |word|
      pattern = "%#{Item.sanitize_sql_like(word)}%"
      scope = scope.where("items.name ILIKE :pattern OR items.description ILIKE :pattern", pattern: pattern)
    end

    scope.order(created_at: :desc).limit(12)
  end
end
