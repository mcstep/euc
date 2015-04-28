class AvatarUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave

  process :tags => ['euc_avatar']
  process :convert => 'jpg'
  cloudinary_transformation :quality => 80, :width => 200, :height => 200, :crop => :thumb

  # Heroku has a read-only /public/uploads dir
  def cache_dir
    "#{Rails.root}/tmp/uploads"
  end
end
