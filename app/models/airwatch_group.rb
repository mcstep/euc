# == Schema Information
#
# Table name: airwatch_groups
#
#  id         :integer          not null, primary key
#  text_id    :string
#  numeric_id :string
#  type       :string
#  parent_id  :integer
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_airwatch_groups_on_deleted_at  (deleted_at)
#  index_airwatch_groups_on_parent_id   (parent_id)
#

class AirwatchGroup < ActiveRecord::Base
  acts_as_paranoid

  validates :text_id,    presence: true
  validates :numeric_id, presence: true
end
