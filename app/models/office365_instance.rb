# == Schema Information
#
# Table name: office365_instances
#
#  id           :integer          not null, primary key
#  group_name   :string
#  group_region :string
#  deleted_at   :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_office365_instances_on_deleted_at  (deleted_at)
#

class Office365Instance < ActiveRecord::Base
  acts_as_paranoid

  validates :group_region, presence: true, if: lambda{ group_name.present? }
end
