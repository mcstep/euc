# == Schema Information
#
# Table name: airwatch_groups
#
#  id                   :integer          not null, primary key
#  airwatch_instance_id :integer
#  company_id           :integer
#  text_id              :string
#  numeric_id           :string
#  kind                 :string
#  deleted_at           :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_airwatch_groups_on_deleted_at  (deleted_at)
#

class AirwatchGroup < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :airwatch_instance
  belongs_to :company

  validates :text_id,           presence: true
  validates :numeric_id,        presence: true
  validates :airwatch_instance, presence: true
  validates :company,           presence: true

  def self.instantiate(user_integration)
    condition = {
      company_id:           user_integration.user.company_id,
      airwatch_instance_id: user_integration.integration.airwatch_instance_id
    }

    return attempt if attempt = where(condition).first

    data = user_integration.integration.airwatch_instance.add_group(user_integration.airwatch_group_name)
    AirwatchGroup.create!(
      airwatch_instance: user_integration.integration.airwatch_instance,
      company:           user_integration.user.company,
      text_id:           user_integration.airwatch_group_name,
      numeric_id:        data['Value'],
      kind:              'Prospect'
    )
  end
end
