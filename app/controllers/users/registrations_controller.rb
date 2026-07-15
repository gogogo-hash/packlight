class Users::RegistrationsController < DeviseInvitable::RegistrationsController
  include TurnstileProtected

  private

  def build_resource_for_turnstile_failure
    build_resource(sign_up_params)
  end
end
