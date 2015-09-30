# == Schema Information
#
# Table name: airwatch_groups
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  group_id     :string(255)
#  group_id_num :integer
#  parent_id    :integer
#  domain       :string(255)
#  group_type   :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

class Upgrade::AirwatchGroup < ActiveRecord::Base
  self.table_name = Upgrade.table('airwatch_groups')
  establish_connection :import
end
