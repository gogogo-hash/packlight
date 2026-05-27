class Admin::ItemsController < Admin::ApplicationController
  def index
    @items = Item.all.order(last_scanned_at: :desc)
  end

  def scan
      file_source_type = ENV.fetch("FILE_SOURCE_TYPE")
      case file_source_type
      when "local"
        file_source_path = ENV.fetch("FILE_SOURCE_PATH")
        scanner = SmbScannerService.new(file_source_type, file_source_path)
      when "smb"

        smb_host = ENV.fetch("SMB_HOST")
        smb_username = ENV.fetch("SMB_USERNAME", nil)
        smb_password = ENV.fetch("SMB_PASSWORD", nil)
        scanner = SmbScannerService.new(smb_host, smb_username, smb_password)
      when "google_drive"
        google_drive_folder_id = ENV.fetch("GOOGLE_DRIVE_FOLDER_ID")
        scanner = SmbScannerService.new(file_source_type, google_drive_folder_id)
      else
        raise ArgumentError, "Unknown FILE_SOURCE_TYPE: #{file_source_type}"
      end

      items_data = scanner.scan_and_create_items
      redirect_to admin_items_path, notice: "Scan started. Processing #{items_data.length} items."
  end
end
