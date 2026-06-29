class User < ApplicationRecord
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :lockable, :timeoutable,
         :omniauthable, omniauth_providers: [ :google_oauth2 ]

  has_many :items, foreign_key: :admin_id, dependent: :restrict_with_error
  has_many :comments, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  def admin?
    admin == true
  end

  def self.from_omniauth(auth)
      where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
        user.email = auth.info.email
        user.password = Devise.friendly_token[0, 20]
      end.tap do |user|
        user.google_token = auth.credentials.token
        if auth.credentials.refresh_token.present?
          user.google_refresh_token = auth.credentials.refresh_token
        end
        user.google_token_expires_at = auth.credentials.expires_at
        user.save
      end
  end
end
