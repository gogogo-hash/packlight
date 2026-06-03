class Admin::ItemsController < Admin::ApplicationController
  def index
    @items = Item.all.order(last_scanned_at: :desc)
  end

  def scan
      file_source_type = params[:file_source_type]
      user             = params[:user_id]
      case file_source_type
      when "local"
        file_source_path = ENV.fetch("FILE_SOURCE_PATH")
        scanner = ScannerService.new(file_source_type, file_source_path)
      when "smb"

        smb_host = ENV.fetch("SMB_HOST")
        smb_username = ENV.fetch("SMB_USERNAME", nil)
        smb_password = ENV.fetch("SMB_PASSWORD", nil)
        scanner = ScannerService.new(smb_host, smb_username, smb_password)
      when "google_drive"
        scanner = ScannerService.new(file_source_type, nil, user)
      else
        raise ArgumentError, "Unknown FILE_SOURCE_TYPE: #{file_source_type}"
      end

      items_data = scanner.scan_and_create_items
      redirect_to admin_items_path, notice: "Scan started. Processing #{items_data.length} items."
  end
end
