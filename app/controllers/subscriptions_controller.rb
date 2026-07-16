class SubscriptionsController < ApplicationController
  include PacklightAuthorization

  before_action :authenticate_user!
  before_action :set_packlight_admin
  before_action :authorize_packlight_viewer!
  before_action :set_subscribable

  def create
    subscription = current_user.subscriptions.build(subscribable: @subscribable)

    if subscription.save
      redirect_to subscribable_path, notice: "Subscribed successfully."
    else
      redirect_to subscribable_path, alert: "Could not subscribe."
    end
  end

  def destroy
    subscription = current_user.subscriptions.find_by(
      subscribable: @subscribable
    )
    subscription&.destroy
    redirect_to subscribable_path, notice: "Unsubscribed."
  end

  private

  def set_subscribable
    @subscribable = @admin.items.find(params[:item_id])
  end

  def subscribable_path
    packlight_item_path(packlight_id: @admin.packlight_id, id: @subscribable.id)
  end
end
