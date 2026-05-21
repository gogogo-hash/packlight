class SmbScannerService
  VALID_FILE_SOURCES = %w[local smb google_drive].freeze

  def initialize(file_source_type_or_host, file_source_path_or_username = nil, smb_password = nil)
    # Support both old and new initialization
    if file_source_type_or_host.in?(VALID_FILE_SOURCES)
      # New adapter-based initialization
      @file_source_type = file_source_type_or_host
      @file_source_path = file_source_path_or_username
      @adapter = create_adapter
    else
      # Legacy SMB initialization (backward compatibility)
      @file_source_type = "smb"
      @smb_host = file_source_type_or_host
      @smb_username = file_source_path_or_username
      @smb_password = smb_password
      @adapter = FileSourceAdapters::SmbAdapter.new(@smb_host, @smb_username, @smb_password)
    end
  end

  def scan_and_create_items(share_path = "items")
    begin
      items_data = @adapter.scan_items(share_path)

      items_data.each do |item_data|
        create_or_update_item(item_data)
      end

      items_data
    rescue => e
      Rails.logger.error("File source scan error: #{e.message}")
      raise
    end
  end

  private

  def create_adapter
    case @file_source_type
    when "local"
      FileSourceAdapters::LocalDirectoryAdapter.new(@file_source_path)
    when "smb"
      raise ArgumentError, "SMB adapter not yet available. Please use file_source_type='local' for testing."
    when "google_drive"
      raise ArgumentError, "Google Drive adapter not yet available. Please use file_source_type='local' for testing."
    else
      raise ArgumentError, "Unknown file source type: #{@file_source_type}. Valid types: #{VALID_FILE_SOURCES.join(', ')}"
    end
  end

  def create_or_update_item(item_data)
    item = Item.find_or_create_by(file_folder_path: item_data[:folder_name], name: item_data[:folder_name], description: "Scanned from file source", price: 0.0)

    item_data[:photos].each do |photo_data|
      photo = item.photos.find_or_create_by(file_name: photo_data[:file_name])
      photo.update(
        image_data: photo_data[:image_data],
        order: photo_data[:order]
      )
    end

    ProcessItemJob.perform_later(item.id)
  end
end
