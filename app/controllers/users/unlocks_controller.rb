class Users::UnlocksController < Devise::UnlocksController
  include TurnstileProtected
end
