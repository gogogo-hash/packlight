class Admin::ItemsController < Admin::ApplicationController
  before_action :set_item, only: [ :edit, :update ]

  def index
    @items = Item.all.order(last_scanned_at: :desc)
  end

  def scan
      file_source_type = params[:file_source_type]
      user             = params[:user_id]
      file_source_path = params[:file_source_path]
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
        scanner = ScannerService.new(file_source_type, file_source_path, user)
      else
        raise ArgumentError, "Unknown FILE_SOURCE_TYPE: #{file_source_type}"
      end

      items_data = scanner.scan_and_create_items
      redirect_to admin_items_path, notice: "Scan started. Processing #{items_data.length} items."
  end

  def edit
    # Renders admin/items/edit.html.erb inside the "modal" turbo frame automatically
  end

  def update
    respond_to do |format|
      if @item.update(item_params)
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(ActionView::RecordIdentifier.dom_id(@item), partial: "admin/items/item_row", locals: { item: @item }),
            turbo_stream.update("modal", "")
          ]
        end
        format.html { redirect_to admin_items_path, notice: "Item was successfully updated." }
      else
        format.turbo_stream { render :edit, status: :unprocessable_entity }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end



  private

  def set_item
    @item = Item.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:price, :description)
  end
end
