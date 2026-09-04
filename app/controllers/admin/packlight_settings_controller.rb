class Admin::PacklightSettingsController < Admin::ApplicationController
  def update
    current_user.update(packlight_public: params[:user][:packlight_public])

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to admin_items_path }
    end
  end
end
