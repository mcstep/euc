# == Schema Information
#
# Table name: invitations
#
#  id                            :integer          not null, primary key
#  sender_id                     :integer
#  recipient_email               :string(255)
#  token                         :string(255)
#  recipient_username            :string(255)
#  recipient_firstname           :string(255)
#  recipient_lastname            :string(255)
#  recipient_title               :string(255)
#  recipient_company             :string(255)
#  created_at                    :datetime
#  updated_at                    :datetime
#  expires_at                    :datetime
#  region                        :string(255)
#  potential_seats               :integer
#  deleted_at                    :datetime
#  airwatch_trial                :boolean
#  google_apps_trial             :boolean
#  airwatch_user_id              :integer
#  eula_accept_date              :datetime
#  acc_expiration_reminder_email :boolean
#  reg_code_id                   :integer
#  airwatch_admin_user_id        :integer
#
# Indexes
#
#  index_invitations_on_deleted_at  (deleted_at)
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
