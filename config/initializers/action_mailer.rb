Rails.application.config.action_mailer.delivery_method = :smtp
Rails.application.config.action_mailer.smtp_settings = {
  address: "smtp.sendgrid.net",
  port: 587,
  authentication: :plain,
  user_name: ENV.fetch("SENDGRID_USERNAME", "apikey"),
  password: ENV.fetch("SENDGRID_API_KEY", "")
}

Rails.application.config.action_mailer.default_url_options = {
  host: ENV.fetch("RAILS_HOST", "localhost:3000"),
  protocol: ENV.fetch("RAILS_PROTOCOL", "http")
}

Rails.application.config.action_mailer.default_options = { from: ENV.fetch("MAIL_FROM", "noreply@packlight.local") }
