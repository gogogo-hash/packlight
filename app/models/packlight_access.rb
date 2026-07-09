class PacklightAccess < ApplicationRecord
  belongs_to :admin, class_name: "User", foreign_key: :packlight_id, primary_key: :packlight_id, optional: true

  before_validation :normalize_email

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :packlight_id, presence: true
  validates :email, uniqueness: { scope: :packlight_id, case_sensitive: false }

  private

  def normalize_email
    self.email = email.strip.downcase if email.present?
  end
end
