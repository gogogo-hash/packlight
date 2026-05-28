class GeminiImageProcessor
  ALLOWED_MIME_TYPES = %w[
    image/png
    image/jpeg
    image/webp
    image/heic
    image/heif
  ].freeze

  def self.valid?(file_path)
    detected_type = Marcel::MimeType.for(File.open(file_path))
    ALLOWED_MIME_TYPES.include?(detected_type)
  end
end
