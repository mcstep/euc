# == Schema Information
#
# Table name: profiles
#
#  id            :integer          not null, primary key
#  name          :string
#  home_template :string
#  support_email :string
#  group_name    :string
#  supports_vidm :boolean          default(TRUE), not null
#  deleted_at    :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_profiles_on_deleted_at  (deleted_at)
#

class Profile < ActiveRecord::Base
  acts_as_paranoid

  has_many :profile_integrations

  def directory_groups
    [
      group_name,
      ('VIDMUsers' if supports_vidm)
    ].compact
  end
end
