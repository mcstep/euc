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
#  crm_kind        :integer
#  crm_id          :string
#  crm_data        :text
#  crm_fetch_error :boolean          default(FALSE), not null
#
# Indexes
#
#  index_invitations_on_created_at    (created_at)
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
  has_many :extensions,  class_name: 'Upgrade::Extension', foreign_key: 'recipient'

  enum invitation_status: [:pending, :active, :expired, :declined]

  def domain
    Upgrade::Domain.where(name: recipient_email.split('@').last, status: 0).first
  end

  def role
    domain.present? ? User::ROLES[:admin] : User::ROLES[:basic]
  end
end
