class AvatarUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave

  process :tags => ['euc_avatar']
  process :convert => 'jpg'
  process :resize_to_fit => [200, 200]

  # Heroku has a read-only /public/uploads dir
  def cache_dir
    "#{Rails.root}/tmp/uploads"
  end
end
