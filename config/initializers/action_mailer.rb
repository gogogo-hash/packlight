Resend.api_key = ENV.fetch("RESEND_API_KEY", "")
Rails.application.config.action_mailer.delivery_method = :resend

Rails.application.config.action_mailer.default_url_options = {
  host: ENV.fetch("RAILS_HOST", "localhost:3000"),
  protocol: ENV.fetch("RAILS_PROTOCOL", "http")
}

Rails.application.config.action_mailer.default_options = { from: ENV.fetch("MAIL_FROM", "noreply@packlight.community") }
