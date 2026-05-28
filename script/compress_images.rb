photo = Photo.find(61)

image = MiniMagick::Image.read(photo.image_data)

image.define "jpeg:extent=2mb"

compressed_data = image.to_blob
photo.update!(image_data: compressed_data)
