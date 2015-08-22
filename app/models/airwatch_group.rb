# == Schema Information
#
# Table name: airwatch_groups
#
#  id                   :integer          not null, primary key
#  airwatch_instance_id :integer
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

  belongs_to :airwatch_instance, -> { with_deleted }
  belongs_to :company, -> { with_deleted }

  validates :text_id,           presence: true
  validates :numeric_id,        presence: true
  validates :airwatch_instance, presence: true

  def self.produce(user_integration)
    condition = {
      text_id:              user_integration.airwatch_group_name,
      airwatch_instance_id: user_integration.integration.airwatch_instance_id
    }

    if attempt = where(condition).first
      return attempt
    end

    data = user_integration.integration.airwatch_instance.add_group(user_integration.airwatch_group_name)
    AirwatchGroup.create!(
      airwatch_instance: user_integration.integration.airwatch_instance,
      text_id:           user_integration.airwatch_group_name,
      numeric_id:        data['Value'],
      kind:              'Prospect'
    )
  end
end
