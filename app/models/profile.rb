# == Schema Information
#
# Table name: profiles
#
#  id         :integer          not null, primary key
#  name       :string
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_profiles_on_deleted_at  (deleted_at)
#

class Profile < ActiveRecord::Base
  acts_as_paranoid

  has_many :profile_integrations
end
