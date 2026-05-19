class Admin::ItemsController < Admin::ApplicationController
  def index
    @items = Item.all.order(last_scanned_at: :desc)
  end

  def scan
    begin
      smb_host = ENV.fetch("SMB_HOST")
      smb_username = ENV.fetch("SMB_USERNAME", nil)
      smb_password = ENV.fetch("SMB_PASSWORD", nil)

      scanner = SmbScannerService.new(smb_host, smb_username, smb_password)
      items_data = scanner.scan_and_create_items

      redirect_to admin_items_path, notice: "Scan started. Processing #{items_data.length} items."
    rescue => e
      Rails.logger.error("Scan error: #{e.message}")
      redirect_to admin_items_path, alert: "Scan failed: #{e.message}"
    end
  end
end
