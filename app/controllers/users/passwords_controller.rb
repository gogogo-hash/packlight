class Users::PasswordsController < Devise::PasswordsController
  include TurnstileProtected
end
