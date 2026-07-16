module TurnstileProtected
  extend ActiveSupport::Concern

  included do
    before_action :validate_bot_challenge, only: [ :create ]
  end

  private

  def validate_bot_challenge
    return if valid_turnstile?

    build_resource_for_turnstile_failure
    flash.now[:alert] = "Bot verification failed. Please try again."
    render :new, status: :unprocessable_entity, formats: :html
  end

  # Devise's own #new action just does `resource_class.new` with no params.
  # Controllers that have a whitelisted params method (sign_in_params,
  # sign_up_params, ...) override this to preserve what the user typed.
  def build_resource_for_turnstile_failure
    self.resource = resource_class.new
  end
end
