class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "onboarding@resend.dev")
  layout "mailer"
end
