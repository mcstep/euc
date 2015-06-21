# == Schema Information
#
# Table name: airwatch_instances
#
#  id              :integer          not null, primary key
#  group_name      :string
#  api_key         :string
#  host            :string
#  user            :string
#  password        :string
#  parent_group_id :string
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_airwatch_instances_on_deleted_at  (deleted_at)
#

class AirwatchInstance < ActiveRecord::Base
  acts_as_paranoid

  validates :host,            presence: true
  validates :user,            presence: true
  validates :password,        presence: true
  validates :parent_group_id, presence: true
  validates :group_name,      presence: true
end
