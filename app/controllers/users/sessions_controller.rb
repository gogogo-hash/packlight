class Users::SessionsController < Devise::SessionsController
  before_action :validate_bot_challenge, only: [ :create ]

  private

  def validate_bot_challenge
    unless valid_turnstile?
      self.resource = resource_class.new(sign_in_params)
      flash.now[:alert] = "Bot verification failed. Please try again."
      respond_with_navigational(resource) { render :new, status: :unprocessable_entity }
    end
  end
end
