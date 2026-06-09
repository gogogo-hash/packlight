class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    auth = request.env["omniauth.auth"]
    granted_scopes = auth.dig("credentials", "scope") || ""


      # if granted_scopes.include?("drive.readonly")
      #   if current_user&.respond_to?(:admin?) && current_user.admin?
      #     current_user.update!(
      #           google_drive_token: auth.credentials.token,
      #           google_drive_refresh_token: auth.credentials.refresh_token
      #         )

      #         # Adjust this path to wherever your admin dashboard lives
      #         redirect_to admin_items_path, notice: "Google Drive successfully connected for scanning!"
      #   else
      #         redirect_to root_path, alert: "Unauthorized. Only administrators can connect Google Drive."
      #   end

      # else

      @user = User.from_omniauth(request.env["omniauth.auth"])

      if @user.persisted?
        flash[:notice] = I18n.t("devise.omniauth_callbacks.success", kind: "Google")
        sign_in_and_redirect @user, event: :authentication
      else
        # Avoid overflowing cookie session storage if auth data is huge
        session["devise.google_data"] = request.env["omniauth.auth"].except("extra")
        redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
      end
  end

  def failure
    redirect_to root_path, alert: "Authentication failed, please try again."
  end
end
