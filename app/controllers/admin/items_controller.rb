class Admin::ItemsController < Admin::ApplicationController
  before_action :set_item, only: [ :edit, :update ]

  def index
    @items = current_user.items.order(created_at: :desc)
    @packlight_accesses = current_user.packlight_accesses.order(created_at: :desc)
    @packlight_access = PacklightAccess.new
  end

  def new
    @item = Item.new
  end

  def create
    uploaded_files = Array(params[:photos]).compact_blank

    if uploaded_files.empty?
      redirect_to new_admin_item_path, alert: "Please select at least one photo."
      return
    end

    item = current_user.items.create!(status: "pending")

    uploaded_files.each_with_index do |file, index|
      raw_data = file.read
      image_data = compress_photo(raw_data)
      next if image_data.nil?

      item.photos.create!(
        file_name: file.original_filename,
        image_data: image_data,
        order: index
      )

      if index == 0
        thumbnail = generate_thumbnail(raw_data)
        item.update(thumbnail: thumbnail) if thumbnail
      end
    end

    ProcessItemJob.perform_later(item.id)
    redirect_to admin_items_path, notice: "Item uploaded. AI processing has started."
  rescue => e
    Rails.logger.error("Manual item creation failed: #{e.message}")
    redirect_to new_admin_item_path, alert: "Something went wrong. Please try again."
  end

  def scan
    file_source_type = params[:file_source_type]
    file_source_path = params[:file_source_path]

    case file_source_type
    when "local"
      file_source_path = ENV.fetch("FILE_SOURCE_PATH")
      scanner = ScannerService.new(file_source_type, file_source_path, current_user)
    when "smb"
      smb_host = ENV.fetch("SMB_HOST")
      smb_username = ENV.fetch("SMB_USERNAME", nil)
      smb_password = ENV.fetch("SMB_PASSWORD", nil)
      scanner = ScannerService.new(smb_host, smb_username, smb_password)
    when "google_drive"
      scanner = ScannerService.new(file_source_type, file_source_path, current_user)
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
    @item = current_user.items.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:price, :description)
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
    Rails.logger.error "Photo compression failed: #{e.message}"
    nil
  end
end
