class User < ApplicationRecord
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :lockable, :timeoutable,
         :omniauthable, omniauth_providers: [ :google_oauth2 ]

  has_many :items, foreign_key: :admin_id, dependent: :restrict_with_error
  has_many :comments, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :packlight_accesses, foreign_key: :packlight_id, primary_key: :packlight_id, dependent: :destroy

  before_create :generate_packlight_id

  BETA_COHORT_AI_LISTING_LIMIT = 100
  STANDARD_AI_LISTING_LIMIT = 5
  STANDARD_LISTING_LIMIT = 10

  def beta_cohort?
    beta_cohort == true
  end

  def ai_listing_limit
    beta_cohort? ? BETA_COHORT_AI_LISTING_LIMIT : STANDARD_AI_LISTING_LIMIT
  end

  def ai_listing_limit_reached?
    ai_listings_count >= ai_listing_limit
  end

  def remaining_ai_listings
    [ ai_listing_limit - ai_listings_count, 0 ].max
  end

  def listing_limit_reached?
    return false if beta_cohort?
    items.count >= STANDARD_LISTING_LIMIT
  end

  private

  def generate_packlight_id
    loop do
      self.packlight_id = SecureRandom.alphanumeric(8).downcase
      break unless User.exists?(packlight_id: packlight_id)
    end
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
