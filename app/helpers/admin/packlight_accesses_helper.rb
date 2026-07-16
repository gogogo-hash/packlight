module Admin::PacklightAccessesHelper
  def packlight_invite_share_text(packlight_access)
    signup_url = new_user_registration_url(invited_email: packlight_access.email)
    page_url = packlight_page_url(packlight_id: current_user.packlight_id)

    <<~TEXT.strip
      I've invited you to view my Packlight garage sale page: #{page_url}

      Don't have a Packlight account yet? Sign up at #{signup_url} using this exact email address so you're recognized as invited: #{packlight_access.email}
    TEXT
  end
end
