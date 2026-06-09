# app/controllers/admin/google_drive_connections_controller.rb
class Admin::GoogleDriveConnectionsController < ApplicationController
  # before_action :authenticate_user!
  # before_action :ensure_admin!

  # Step 1: Redirect the Admin to Google to authorize Drive
  def connect
    redirect_to oauth_client.authorization_uri.to_s, allow_other_host: true
  end

  # Step 2: Handle the code Google sends back and save the tokens
  def callback
    if params[:code].present?
      client = oauth_client
      client.code = params[:code]

      # Exchange authorization code for access/refresh tokens
      token_response = client.fetch_access_token!

      current_user.update!(
        google_drive_token: token_response["access_token"],
        google_drive_refresh_token: token_response["refresh_token"],
        google_drive_token_expires_at: (Time.current + token_response["expires_in"].to_i).to_i
      )

      redirect_to admin_items_path, notice: "Google Drive successfully connected for scanning!"
    else
      redirect_to admin_items_path, alert: "Authorization failed or denied by user."
    end
  end

  private

  def ensure_admin!
    redirect_to root_path, alert: "Unauthorized" unless current_user&.admin?
  end

  def oauth_client
    Signet::OAuth2::Client.new(
      client_id: ENV["GOOGLE_CLIENT_ID"],
      client_secret: ENV["GOOGLE_CLIENT_SECRET"],
      authorization_uri: "https://accounts.google.com/o/oauth2/auth",
      token_credential_uri: "https://oauth2.googleapis.com/token",
      scope: "https://www.googleapis.com/auth/drive.readonly",
      # Combines your dynamic base domain with your explicit callback path
      redirect_uri: admin_google_drive_callback_url,
      options: {
        prompt: "consent",
        access_type: "offline",
        include_granted_scopes: "true"
      }
    )
  end
end
