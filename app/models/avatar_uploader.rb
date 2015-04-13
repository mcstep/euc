class AvatarUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave

  process :tags => ['euc_avatar']
  process :convert => 'jpg'
  process :resize_to_fit => [200, 200]
end
