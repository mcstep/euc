# == Schema Information
#
# Table name: profiles
#
#  id                        :integer          not null, primary key
#  name                      :string
#  home_template             :string
#  support_email             :string
#  group_name                :string
#  group_region              :string
#  supports_vidm             :boolean          default(TRUE), not null
#  deleted_at                :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  requires_verification     :boolean          default(FALSE), not null
#  airwatch_admins_supported :boolean          default(FALSE), not null
#
# Indexes
#
#  index_profiles_on_deleted_at  (deleted_at)
#

class Profile < ActiveRecord::Base
  acts_as_paranoid

  validates :name, presence: true
  validates :group_region, presence: true, if: :directory_groups?

  has_many :profile_integrations, inverse_of: :profile

  accepts_nested_attributes_for :profile_integrations, allow_destroy: true

  def directory_groups
    [
      group_name,
      ('VIDMUsers' if supports_vidm)
    ].reject(&:blank?)
  end

  def directory_groups?
    directory_groups.any?
  end
end
