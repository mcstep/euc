# == Schema Information
#
# Table name: users
#
#  id                :integer          not null, primary key
#  username          :string(255)
#  email             :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  invitation_id     :integer
#  invitation_limit  :integer
#  role              :integer
#  display_name      :string(255)
#  company           :string(255)
#  title             :string(255)
#  invitations_used  :integer          default(0)
#  total_invitations :integer          default(5)
#  avatar            :string(255)
#
# Indexes
#
#  index_users_on_invitation_id  (invitation_id)
#

class Upgrade::User < ActiveRecord::Base
  self.table_name = Upgrade.table('users')
  establish_connection :import

  belongs_to :invitation
  has_many :sent_invitations, class_name: 'Upgrade::Invitation', foreign_key: 'sender_id'
  has_many :extensions,  class_name: 'Upgrade::Extension', foreign_key: 'extended_by'
end
