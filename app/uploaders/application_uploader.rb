class ApplicationUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave

  # Heroku has a read-only /public/uploads dir
  def cache_dir
    "#{Rails.root}/tmp/uploads"
  end
end