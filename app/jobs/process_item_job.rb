class ProcessItemJob < ApplicationJob
  queue_as :default

  def perform(item_id)
    item = Item.find(item_id)
    item.update(status: "pending")

    begin
      # Gather all photos for this item
      photos = item.photos.order(:order)
      return if photos.empty?

      # Prepare images for Claude API
      # image_data = photos.map do |photo|
      #   {
      #     type: "image",
      #     source: {
      #       type: "base64",
      #       media_type: "image/jpeg",
      #       data: Base64.strict_encode64(photo.image_data)
      #     }
      #   }
      # end

      # Call Claude API -NOT IMPLEMENTED YET---
      # client = Anthropic::Client.new
      # response = client.messages.create(
      #   model: "claude-3-5-sonnet-20241022",
      #   max_tokens: 1024,
      #   messages: [
      #     {
      #       role: "user",
      #       content: image_data + [
      #         {
      #           type: "text",
      #           text: "Analyze these product images. Provide a JSON response with: name (product name), description (detailed description), price (numeric price). Return only valid JSON."
      #         }
      #       ]
      #     }
      #   ]
      # )

      # Parse Claude response
      # response_text = response.content[0].text
      # result = JSON.parse(response_text)

      # Update item with Claude results
      item.update(
        # name: result["name"],
        # description: result["description"],
        # price: result["price"],
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
end
