class Admin::ItemsController < Admin::ApplicationController
  before_action :set_item, only: [ :edit, :update, :destroy, :mark_sold, :mark_reviewed ]

  def index
    @items = current_user.items.order(created_at: :desc)
    @activity_items = current_user.items.includes(:comments, :item_review).select(&:new_activity?)
    @packlight_accesses = current_user.packlight_accesses.order(created_at: :desc)
    @packlight_access = PacklightAccess.new
  end

  def new
    @item = Item.new
    @mode = params[:mode] == "manual" ? "manual" : "ai"
  end

  def create
    if current_user.listing_limit_reached?
      redirect_to new_admin_item_path, alert: "You've reached the #{User::STANDARD_LISTING_LIMIT}-listing limit for beta."
      return
    end

    if params[:mode] == "manual"
      create_manual
    else
      create_with_ai
    end
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

  def mark_sold
    @item.update(status: "sold")
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(ActionView::RecordIdentifier.dom_id(@item), partial: "admin/items/item_row", locals: { item: @item })
      end
      format.html { redirect_to admin_items_path, notice: "Item marked as sold." }
    end
  end

  def destroy
    @item.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(ActionView::RecordIdentifier.dom_id(@item)) }
      format.html { redirect_to admin_items_path, notice: "Item was successfully deleted." }
    end
  end

  def mark_reviewed
    @item.mark_reviewed!
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove("activity_#{ActionView::RecordIdentifier.dom_id(@item)}") }
      format.html { redirect_to admin_items_path, notice: "Item marked as reviewed." }
    end
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

  def item_manual_params
    params.require(:item).permit(:name, :description, :price, :status)
  end

  def create_with_ai
    if current_user.ai_listing_limit_reached?
      redirect_to new_admin_item_path, alert: "You've reached the #{current_user.ai_listing_limit}-listing AI limit for beta. Use Manual Entry to add more items."
      return
    end

    uploaded_files = Array(params[:photos]).compact_blank

    if uploaded_files.empty?
      redirect_to new_admin_item_path, alert: "Please select at least one photo."
      return
    end

    reserved = User.where(id: current_user.id)
      .where("ai_listings_count < ?", current_user.ai_listing_limit)
      .update_all("ai_listings_count = ai_listings_count + 1")

    if reserved.zero?
      redirect_to new_admin_item_path, alert: "You've reached the #{current_user.ai_listing_limit}-listing AI limit for beta. Use Manual Entry to add more items."
      return
    end

    item = current_user.items.create!(status: "pending")
    attach_photos(item, uploaded_files)

    ProcessItemJob.perform_later(item.id)
    redirect_to admin_items_path, notice: "Item uploaded. AI processing has started."
  rescue => e
    Rails.logger.error("AI item creation failed: #{e.message}")
    redirect_to new_admin_item_path, alert: "Something went wrong. Please try again."
  end

  def create_manual
    @item = current_user.items.new(item_manual_params)

    if @item.save
      attach_photos(@item, Array(params[:photos]).compact_blank)
      redirect_to admin_items_path, notice: "Item created."
    else
      @mode = "manual"
      render :new, status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.error("Manual item creation failed: #{e.message}")
    @mode = "manual"
    flash.now[:alert] = "Something went wrong. Please try again."
    render :new, status: :unprocessable_entity
  end

  def attach_photos(item, uploaded_files)
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
