class ScannerService
  VALID_FILE_SOURCES = %w[local smb google_drive].freeze

  def initialize(file_source_type, file_source_path = nil, user = nil, smb_password = nil)
    # Support both old and new initialization
    if file_source_type.in?(VALID_FILE_SOURCES)
      # New adapter-based initialization
      @file_source_type = file_source_type
      @file_source_path = file_source_path
      @user = user
      @adapter = create_adapter
    else
      # Legacy SMB initialization (backward compatibility)
      @file_source_type = "smb"
      @smb_host = file_source_type
      @smb_username = file_source_path
      @smb_password = smb_password
      @adapter = FileSourceAdapters::SmbAdapter.new(@smb_host, @smb_username, @smb_password)
    end
  end

  def scan_and_create_items(share_path = "items")
    begin
      items_data = @adapter.scan_items
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
      FileSourceAdapters::GoogleDriveAdapter.new(@user, @file_source_path)
    else
      raise ArgumentError, "Unknown file source type: #{@file_source_type}. Valid types: #{VALID_FILE_SOURCES.join(', ')}"
    end
  end

  def create_or_update_item(item_data)
    item = Item.find_or_create_by(file_folder_path: item_data[:file_folder_path], thumbnail: item_data[:thumbnail])
    requires_processing = item.previously_new_record?

    item_data[:photos].each do |photo_data|
      photo = item.photos.find_or_initialize_by(file_name: photo_data[:file_name], item_id: item.id)
      photo.assign_attributes(
        image_data: photo_data[:image_data],
        order: photo_data[:order]
      )
      if photo.changed?
        photo.save
        requires_processing = true
      end
  end

    ProcessItemJob.perform_later(item.id) if requires_processing
  end
end
