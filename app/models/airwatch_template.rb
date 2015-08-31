# == Schema Information
#
# Table name: airwatch_templates
#
#  id                   :integer          not null, primary key
#  airwatch_instance_id :integer
#  domain               :string
#  data                 :text
#  deleted_at           :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_airwatch_templates_on_deleted_at  (deleted_at)
#

class AirwatchTemplate < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :airwatch_instance, -> { with_deleted }

  validates :airwatch_instance, presence: true
  validates :domain, presence: true, uniqueness: { scope: [:airwatch_instance_id, :deleted_at] }

  serialize :data

  def self.produce(user_integration)
    condition = {
      domain:               user_integration.user.email.split('@', 2).last,
      airwatch_instance_id: user_integration.integration.airwatch_instance_id
    }

    return attempt if attempt = where(condition).first

    data = user_integration.integration.airwatch_instance.generate_template(
      condition[:domain],
      user_integration.user.company_name
    )

    AirwatchTemplate.create!(
      airwatch_instance: user_integration.integration.airwatch_instance,
      domain:            condition[:domain],
      data:              data
    )
  end

  def self.exist?(user_integration)
    condition = {
      domain:               user_integration.user.email.split('@', 2).last,
      airwatch_instance_id: user_integration.integration.airwatch_instance_id
    }

    return attempt if attempt = where(condition).first
  end

  def to_h
    result = {}
    fetch  = lambda do |entry|
      result[entry['name']] = entry['id']
      entry['children'].each{|x| fetch.call(x)} if entry['children']
    end

    fetch.call(data['organizationGroups'])
    result
  end
end
