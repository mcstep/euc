# == Schema Information
#
# Table name: horizon_air_instances
#
#  id            :integer          not null, primary key
#  group_name    :string
#  instance_url  :string
#  instance_port :string
#  api_key       :string
#  deleted_at    :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_horizon_air_instances_on_deleted_at  (deleted_at)
#

class HorizonAirInstance < ActiveRecord::Base
  acts_as_paranoid

  validates :group_name,   presence: true
  validates :group_region, presence: true
  validates :instance_url, presence: true
end
