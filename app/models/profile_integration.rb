# == Schema Information
#
# Table name: profile_integrations
#
#  id                      :integer          not null, primary key
#  profile_id              :integer
#  integration_id          :integer
#  authentication_priority :integer          default(0), not null
#  allow_sharing           :boolean          default(FALSE), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_profile_integrations_on_integration_id  (integration_id)
#  index_profile_integrations_on_profile_id      (profile_id)
#

class ProfileIntegration < ActiveRecord::Base
  belongs_to :profile
  belongs_to :integration

  validates :profile,     presence: true
  validates :integration, presence: true
end
