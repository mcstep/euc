class Upgrade::User < ActiveRecord::Base
  self.table_name = "old.users"

  belongs_to :invitation
  has_many :sent_invitations, class_name: 'Upgrade::Invitation', foreign_key: 'sender_id'
end
