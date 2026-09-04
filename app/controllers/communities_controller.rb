class CommunitiesController < ApplicationController
  before_action :authenticate_user!

  def index
    accessible_packlight_ids = PacklightAccess.where(email: current_user.email).pluck(:packlight_id)

    @users = User.where(packlight_id: accessible_packlight_ids).order(created_at: :asc)

    @public_users = User.where(packlight_public: true)
                         .where.not(packlight_id: accessible_packlight_ids + [ current_user.packlight_id ])
                         .order(created_at: :asc)

    @recent_items = Item.includes(:admin)
                         .joins(:admin)
                         .where(users: { packlight_id: accessible_packlight_ids }, status: "processed")
                         .order(created_at: :desc)
                         .limit(10)

    watched_scope = Item.includes(:admin)
                         .joins(:admin, :subscriptions)
                         .where(subscriptions: { user_id: current_user.id })
                         .where(users: { packlight_id: accessible_packlight_ids }, status: "processed")
                         .order("subscriptions.created_at DESC")
    @pagy, @watched_items = pagy(watched_scope, items: 10)

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
