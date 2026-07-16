module PacklightAuthorization
  extend ActiveSupport::Concern

  private

  def set_packlight_admin
    @admin = User.find_by!(packlight_id: params[:packlight_id])
  rescue ActiveRecord::RecordNotFound
    render_packlight_not_found
  end

  def authorize_packlight_viewer!
    return if current_user == @admin
    return if PacklightAccess.exists?(email: current_user.email.to_s.strip.downcase, packlight_id: @admin.packlight_id)

    render_packlight_not_found
  end

  def render_packlight_not_found
    render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
  end
end
