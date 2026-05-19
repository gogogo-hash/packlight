if ENV["ANTHROPIC_API_KEY"].present?
  Anthropic.configure do |config|
    config.access_token = ENV["ANTHROPIC_API_KEY"]
  end
end

