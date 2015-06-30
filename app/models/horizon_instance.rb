# == Schema Information
#
# Table name: horizon_instances
#
#  id                   :integer          not null, primary key
#  rds_group_name       :string
#  workspace_group_name :string
#  desktops_group_name  :string
#  api_host             :string
#  api_port             :string
#  api_key              :string
#  deleted_at           :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_horizon_instances_on_deleted_at  (deleted_at)
#

class HorizonInstance < ActiveRecord::Base
  acts_as_paranoid

  validates :rds_group_name,       presence: true
  validates :workspace_group_name, presence: true
  validates :desktops_group_name,  presence: true
  validates :group_region,         presence: true
  validates :api_host,             presence: true
end
