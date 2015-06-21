class AvatarUploader < ApplicationUploader
  process tags: ['euc_avatar']
  process convert: 'jpg'
  cloudinary_transformation quality: 80, width: 200, height: 200, crop: :thumb
end