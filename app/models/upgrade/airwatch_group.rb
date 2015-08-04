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

class Upgrade::AirwatchGroup < ActiveRecord::Base
  self.table_name = Upgrade.table('airwatch_groups')
  establish_connection :import
end
