class CommunitiesController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.where(admin: true).order(created_at: :asc)
  end
end
