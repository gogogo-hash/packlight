module FileSourceAdapters
  class LocalDirectoryAdapter
    def initialize(base_path)
      @base_path = File.expand_path(base_path)
      raise ArgumentError, "Path does not exist: #{@base_path}" unless Dir.exist?(@base_path)
    end

    def scan_items(share_path = "items")
      items = []
      existing_folders = Set.new(Item.pluck(:file_folder_path))
      existing_photos = Set.new(
        Item.joins(:photos).pluck("items.file_folder_path", "photos.file_name").map { |f, p| File.join(f, p) }
      )

      Dir.glob(File.join(@base_path, "*")).sort.each do |folder_path|
        next unless File.directory?(folder_path)

        folder_name = File.basename(folder_path)
        photos = list_photos_in_folder(folder_path, existing_photos)

        next if photos.empty?

        items << {
          folder_name: folder_name,
          file_folder_path: folder_path,
          photos: photos
        }
      end
      items
    end

    private

    def list_photos_in_folder(folder_path, existing_photos)
      photos = []
      order = 0
      max_size_bytes = 2 * 1024 * 1024 # 2 MB in bytes

      Dir.glob(File.join(folder_path, "*")).sort.each do |file_path|
        next if existing_photos.include?(file_path)
        next unless File.file?(file_path)
        next unless GeminiImageProcessor.valid?(file_path)

        begin
          if File.size(file_path) > max_size_bytes
            image = MiniMagick::Image.open(file_path)
            image.define "jpeg:extent=2mb"
            image_data = image.to_blob
          else
            image_data = File.read(file_path, mode: "rb")
          end

          photos << {
            file_name: File.basename(file_path),
            image_data: image_data,
            order: order
          }
          order += 1
        rescue StandardError => e
          Rails.logger.warn("Failed to process image #{file_path}: #{e.message}")
        end
      end
      photos
    end
  end
end
