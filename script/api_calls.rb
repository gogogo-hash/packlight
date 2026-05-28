
      client = Gemini.new(
                      credentials: {
                        service: "generative-language-api",
                        api_key: ENV["GEMINI_API_KEY"] },
                      options: { model: "gemini-2.5-flash" }
          )


prompt_text = File.read(Rails.root.join("script/TestPrompt"))

images = Photo.where(item_id: 11).pluck(:image_data)

# Build parts array with all images
parts = images.map do |image_data|
  base64_image = Base64.strict_encode64(image_data)
  {
    inline_data: {
      mime_type: "image/jpeg",
      data: base64_image
    }
  }
end

# Add the prompt text as the final part
parts << { text: prompt_text }

response = client.generate_content({
  contents: {
    role: "user",
    parts: parts
  }
})
