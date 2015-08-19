# == Schema Information
#
# Table name: invitations
#
#  id              :integer          not null, primary key
#  from_user_id    :integer
#  to_user_id      :integer
#  sent_at         :datetime
#  potential_seats :integer
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_invitations_on_deleted_at    (deleted_at)
#  index_invitations_on_from_user_id  (from_user_id)
#  index_invitations_on_to_user_id    (to_user_id)
#

class Upgrade::Invitation < ActiveRecord::Base
  acts_as_paranoid
  
  self.table_name = Upgrade.table('invitations')
  establish_connection :import

  belongs_to :reg_code
  belongs_to :sender, class_name: 'Upgrade::User'
  has_one :recipient, class_name: 'Upgrade::User'

  enum invitation_status: [:pending, :active, :expired, :declined]
end
