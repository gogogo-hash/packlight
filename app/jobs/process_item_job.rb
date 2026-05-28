class ProcessItemJob < ApplicationJob
  queue_as :default

  def perform(item_id)
    item = Item.find(item_id)
    item.update(status: "pending")

    begin
      # Gather all photos for this item
      photos = item.photos.order(:order)
      return if photos.empty?

      # Create Gemini client and fetch prompt. Save for later. We might want to switch to free-tier for demos
      # client = Gemini.new(
      #   credentials: {
      #     service: "generative-language-api",
      #     api_key: ENV["GEMINI_API_KEY"]
      #   },
      #   options: { model: "gemini-2.5-flash" }
      # )

      client = Gemini.new(
          credentials: {
            service: "vertex-ai-api",
            project_id: ENV["GCP_PROJECT_ID"],
            region: "us-central1",
            file_path: "gen-lang-client-0677189465-4e8a9ac5b341.json"
          },
          options: {
            model: "gemini-2.5-flash-lite"
          }
        )
      prompt_text = File.read(Rails.root.join("script/TestPrompt"))

      # Build parts array with all images
      parts = photos.map do |photo|
        base64_image = Base64.strict_encode64(photo.image_data)
        {
          inline_data: {
            mime_type: "image/jpeg",
            data: base64_image
          }
        }
      end

      # Add the prompt text as the final part
      parts << { text: prompt_text }

      # Call Gemini API
      response = client.generate_content({
        contents: {
          role: "user",
          parts: parts
        }
      })

      # Parse response
      raw_text = response.dig("candidates", 0, "content", "parts", 0, "text") || "{}"

      clean_json = raw_text
        .gsub(/\A```json\s*/i, "")
        .gsub(/```\s*\z/, "")
        .strip

      result = JSON.parse(clean_json)




      # Update item with model results
      item.update(
        name: result["title"],
        description: result["description"],
        price: result["price_cad"],
        status: "processed",
        last_scanned_at: Time.current
      )

      Rails.logger.info("Item #{item.id} processed successfully")
    rescue => e

      item.update(status: "error")
      Rails.logger.error("Error processing item #{item.id}: #{e.message}")
      raise
    end
  end





  def create_llm_client(model)
    case model.downcase
    when "anthropic"
      Anthropic::Client.new
    when "gemini"
      Gemini.new
    else
      raise ArgumentError, "Unknown LLM model: #{model}. Valid options: anthropic, gemini"
    end
  end
end
