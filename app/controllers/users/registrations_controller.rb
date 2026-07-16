class Users::RegistrationsController < DeviseInvitable::RegistrationsController
  include TurnstileProtected

  protected

  # Devise's default redirects to root_path, which requires authentication
  # here — bouncing an unconfirmed (not-signed-in) user through that
  # before_action clobbers the "check your email" flash before it renders.
  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end

  private

  def build_resource_for_turnstile_failure
    build_resource(sign_up_params)
  end
end
