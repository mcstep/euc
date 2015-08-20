# == Schema Information
#
# Table name: horizon_instances
#
#  id                  :integer          not null, primary key
#  rds_group_name      :string
#  desktops_group_name :string
#  view_group_name     :string
#  group_region        :string
#  api_host            :string
#  api_port            :string
#  api_key             :string
#  deleted_at          :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  display_name        :string
#
# Indexes
#
#  index_horizon_instances_on_deleted_at  (deleted_at)
#

class HorizonInstance < ActiveRecord::Base
  acts_as_paranoid

  validates :group_region,         presence: true, if: :has_group_name?
  validates :api_host,             presence: true

  def title
    api_host
  end

  def has_group_name?
    rds_group_name? || view_group_name? || desktops_group_name?
  end
end
