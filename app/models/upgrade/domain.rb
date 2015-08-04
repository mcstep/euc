# == Schema Information
#
# Table name: domains
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  status     :integer
#  created_at :datetime
#  updated_at :datetime
#

class Upgrade::Domain < ActiveRecord::Base
  self.table_name = Upgrade.table('domains')
  establish_connection :import

  enum status: [:active, :inactive]
end