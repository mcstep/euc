class Upgrade::Invitation < ActiveRecord::Base
  acts_as_paranoid
  
  self.table_name = "old.invitations"

  belongs_to :reg_code
  belongs_to :sender, class_name: 'Upgrade::User'
  has_one :recipient, class_name: 'Upgrade::User'

  enum invitation_status: [:pending, :active, :expired, :declined]
end
