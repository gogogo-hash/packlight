class Users::SessionsController < Devise::SessionsController
  include TurnstileProtected

  private

  def build_resource_for_turnstile_failure
    self.resource = resource_class.new(sign_in_params)
  end
end
