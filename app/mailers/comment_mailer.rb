class CommentMailer < ApplicationMailer
  default from: ENV.fetch("MAIL_FROM", "noreply@packlight.local")

  def new_comment(comment, recipient)
    @comment = comment
    @item = comment.item
    @recipient = recipient
    @comment_author = comment.user

    mail(to: recipient.email, subject: "New comment on #{@item.name}")
  end
end
