module FileSourceAdapters
  class LocalDirectoryAdapter
    def initialize(base_path)
      @base_path = File.expand_path(base_path)
      raise ArgumentError, "Path does not exist: #{@base_path}" unless Dir.exist?(@base_path)
    end

    # Returns array of hashes with folder info and photos
    # [
    #   {
    #     folder_name: "item_1",
    #     photos: [
    #       { file_name: "photo1.jpg", image_data: <binary>, order: 0 },
    #       { file_name: "photo2.jpg", image_data: <binary>, order: 1 }
    #     ]
    #   }
    # ]
    def scan_items(share_path = "items")
      items = []

      Dir.glob(File.join(@base_path, '*')).sort.each do |folder_path|
        next unless File.directory?(folder_path)

        folder_name = File.basename(folder_path)
        photos = list_photos_in_folder(folder_path)

        next if photos.empty?

        items << {
          folder_name: folder_name,
          photos: photos
        }
      end

      items
    end

    private

    def list_photos_in_folder(folder_path)
      photos = []
      order = 0

      Dir.glob(File.join(folder_path, '*.jpg')).sort.each do |file_path|
        next unless File.file?(file_path)

        image_data = File.read(file_path, mode: 'rb')
        photos << {
          file_name: File.basename(file_path),
          image_data: image_data,
          order: order
        }
        order += 1
      rescue StandardError => e
        Rails.logger.warn("Failed to read image #{file_path}: #{e.message}")
      end

      photos
    end
  end
end
