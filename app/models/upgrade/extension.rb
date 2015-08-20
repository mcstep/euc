# == Schema Information
#
# Table name: extensions
#
#  id                  :integer          not null, primary key
#  extended_by         :integer
#  recipient           :integer
#  reason              :string(255)
#  original_expires_at :datetime
#  revised_expires_at  :datetime
#

class Upgrade::Extension < ActiveRecord::Base
  self.table_name = Upgrade.table('extensions')
  establish_connection :import

  belongs_to :extendor, class_name: 'Upgrade::User', foreign_key: 'extended_by'
  belongs_to :invitation, class_name: 'Upgrade::Invitation', foreign_key: 'recipient'
end