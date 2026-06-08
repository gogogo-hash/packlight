module FileSourceAdapters
  class GoogleDriveAdapter
    def initialize(user)
        @user = User.find_by(id: user)
        @drive_service = Google::Apis::DriveV3::DriveService.new
        @drive_service.authorization = user_credentials
    end

    def list_files
      return unless @user.target_google_folder_id.present?
      query = "'#{@user.target_google_folder_id}' in parents and trashed = false"
    end

    def scan_items
          return [] unless @user.target_google_folder_id.present?
          items = []
          existing_photos = Set.new(
            Item.joins(:photos).pluck("items.file_folder_path", "photos.file_name").map { |f, p| File.join(f, p) }
          )

          subfolders_query = "'#{@user.target_google_folder_id}' in parents and " \
                      "mimeType = 'application/vnd.google-apps.folder' and " \
                      "trashed = false"
debugger
          photo = @drive_service.get_file(@user.target_google_folder_id, fields: "id, name")

          # subfolders = @drive_service.list_files(
          #   q: subfolders_query,
          #   fields: "files(id, name)"
          # ).files.sort_by(&:name)

          subfolders.each do |subfolder|
            folder_name = subfolder.name
            folder_id   = subfolder.id
debugger
            # 3. Look for photos specifically inside this subfolder ID
            photos = list_photos_in_google_folder(folder_id, folder_name, existing_photos)

            next if photos.empty?
            items << {
              folder_name: folder_name,
              file_folder_path: folder_name,
              photos: photos
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
        access_token: @user.google_token,
        refresh_token: @user.google_refresh_token,
        expires_at: @user.google_token_expires_at
      )

      if auth.expired?
        auth.refresh!
        @user.update(
          google_token: auth.access_token,
          google_token_expires_at: auth.expires_at.to_i
        )
      end

      auth
    end

    def list_photos_in_google_folder(folder_id, folder_name, existing_photos)
      # debugger

      photos = []
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
          photos << {
                file_name: photo.name,
                image_data: binary_data, # Figure out how to fetch binary data for this file ID (see Google Drive API docs)
                order: order
              }
            order += 1
        end
      rescue StandardError => e
        Rails.logger.error "Failed to fetch photos for folder #{folder_id}: #{e.message}"
        []
      end
      photos
    end
  end
end
