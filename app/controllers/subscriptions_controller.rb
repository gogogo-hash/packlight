class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_subscribable

  def create
    subscription = current_user.subscriptions.build(subscribable: @subscribable)

    if subscription.save
      redirect_to @subscribable, notice: "Subscribed successfully."
    else
      redirect_to @subscribable, alert: "Could not subscribe."
    end
  end

  def destroy
    subscription = current_user.subscriptions.find_by(
      subscribable: @subscribable
    )
    subscription&.destroy
    redirect_to @subscribable, notice: "Unsubscribed."
  end

  private

  def set_subscribable
    if params[:item_id]
      @subscribable = Item.find(params[:item_id])
    end
  end
end
