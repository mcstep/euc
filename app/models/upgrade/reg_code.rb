# == Schema Information
#
# Table name: reg_codes
#
#  id               :integer          not null, primary key
#  code             :string(255)
#  valid_from       :datetime
#  valid_to         :datetime
#  status           :boolean
#  registrations    :integer
#  account_type     :integer
#  account_validity :integer
#  created_at       :datetime
#  updated_at       :datetime
#

class Upgrade::RegCode < ActiveRecord::Base
  self.table_name = Upgrade.table('reg_codes')
  establish_connection :import

  has_many :invitations
end