module FileSourceAdapters
  class GoogleDriveAdapter
    def initialize(user, _path = nil)
        @user = User.find_by(id: user)
        @drive_service = Google::Apis::DriveV3::DriveService.new
        @drive_service.authorization = user_credentials
        @target_folder_id = _path
    end

    def list_files
      return unless @target_folder_id.present
      query = "'#{@target_folder_id}' in parents and trashed = false"
    end

    def scan_items
          return [] unless @target_folder_id.present?
          items = []
          existing_photos = Set.new(
            Item.joins(:photos).pluck("items.file_folder_path", "photos.file_name").map { |f, p| File.join(f, p) }
          )

          subfolders_query = "'#{@target_folder_id}' in parents and " \
                      "mimeType = 'application/vnd.google-apps.folder' and " \
                      "trashed = false"
          subfolders = @drive_service.list_files(
            q: subfolders_query,
            fields: "files(id, name)"
          ).files.sort_by(&:name)
          subfolders.each do |subfolder|
            folder_name = subfolder.name
            folder_id   = subfolder.id

            # 3. Look for photos specifically inside this subfolder ID
            results = list_photos_in_google_folder(folder_id, folder_name, existing_photos)
            photos = results[:photos]
            thumbnail = results[:thumbnail]

            next if photos.empty?
            items << {
              folder_name: folder_name,
              file_folder_path: folder_name,
              photos: photos,
              thumbnail: thumbnail
            }
          end
          items
    end

    private

    def user_credentials
      auth = Signet::OAuth2::Client.new(
        client_id: ENV["GOOGLE_CLIENT_ID"],
        client_secret: ENV["GOOGLE_CLIENT_SECRET"],
        token_credential_uri: "https://oauth2.googleapis.com/token",
        access_token: @user.google_drive_token,
        refresh_token: @user.google_drive_refresh_token,
        expires_at: @user.google_drive_token_expires_at
      )
      if auth.expired?
        auth.refresh!
        @user.update(
          google_drive_token: auth.access_token,
          google_drive_token_expires_at: auth.expires_at.to_i
        )
      end

      auth
    end

    def list_photos_in_google_folder(folder_id, folder_name, existing_photos)
      photos = []
      thumbnail = nil
      order = 0
      max_size_bytes = 2 * 1024 * 1024 # 2 MB in bytes, TODO: Compress large photos before saving to DB.
      photo_query = "'#{folder_id}' in parents" # Grab everything. Google is not great at filtering by MIME type.
      # TODO: filter files in ruby. This is easier to reason about and debug anyway.


      begin
        response = @drive_service.list_files(
          q: photo_query,
          fields: "files(id, name, mimeType, md5Checksum)"
        )
        # Filter out photos you've already processed previously
        # Google provides an 'md5_checksum' for binary files automatically!
        new_photos = response.files.reject do |photo|
          composite_path = File.join(folder_name, photo.name)
          existing_photos.include?(composite_path)  # Or match by photo.name / photo.id
        end

        new_photos.each do |photo|
          io_stream = StringIO.new
          @drive_service.get_file(photo.id, download_dest: io_stream)
          io_stream.rewind
          binary_data = io_stream.read
          # TODO: This is where we would want to compress large photos.

          thumbnail = generate_thumbnail(binary_data) if order.zero?
          compressed_photo = compress_photo(binary_data)


          photos << {
                file_name: photo.name,
                image_data: compressed_photo, # Figure out how to fetch binary data for this file ID (see Google Drive API docs)
                order: order
              }
            order += 1
        end
      rescue StandardError => e
        Rails.logger.error "Failed to fetch photos for folder #{folder_id}: #{e.message}"
        []
      end
      { photos: photos, thumbnail: thumbnail }
    end


    def generate_thumbnail(binary_data, width: 400, quality: 70)
      image = MiniMagick::Image.read(binary_data)
      image.combine_options do |c|
        c.resize "#{width}x#{width}^"
        c.gravity "center"
        c.extent "#{width}x#{width}"
        c.quality quality.to_s
        c.strip
        c.interlace "Plane"
      end
      image.format "jpeg"
      image.to_blob
    rescue MiniMagick::Error => e
      Rails.logger.error "Thumbnail generation failed: #{e.message}"
      nil
    end

    def compress_photo(binary_data, width: 500, quality: 70)
        image = MiniMagick::Image.read(binary_data)
        image.combine_options do |c|
          c.resize "#{width}x#{width}^"
          c.quality quality.to_s
          c.strip
          c.interlace "Plane"
        end
        image.format "webp"
        image.to_blob
    rescue MiniMagick::Error => e
          Rails.logger.error "Thumbnail generation failed: #{e.message}"
          nil
    end
  end
end
