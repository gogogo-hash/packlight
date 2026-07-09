class Admin::PacklightAccessesController < Admin::ApplicationController
  def create
    email = params[:packlight_access][:email].to_s.strip.downcase
    access = current_user.packlight_accesses.find_or_initialize_by(email: email)

    if access.persisted?
      @message = "#{email} is already invited."
    elsif access.save
      @message = "Invited #{email}."
    else
      @message = access.errors.full_messages.to_sentence
      @message_type = :alert
    end
    @message_type ||= :notice

    @packlight_accesses = current_user.packlight_accesses.order(created_at: :desc)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to admin_items_path }
    end
  end

  def destroy
    access = current_user.packlight_accesses.find(params[:id])
    access.destroy

    @message = "Revoked access for #{access.email}."
    @message_type = :notice
    @packlight_accesses = current_user.packlight_accesses.order(created_at: :desc)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to admin_items_path }
    end
  end
end
