# == Schema Information
#
# Table name: directory_prolongations
#
#  id                  :integer          not null, primary key
#  user_integration_id :integer
#  user_id             :integer
#  reason              :string
#  expiration_date_old :date
#  expiration_date_new :date
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  send_notification   :boolean          default(TRUE), not null
#
# Indexes
#
#  index_directory_prolongations_on_user_id              (user_id)
#  index_directory_prolongations_on_user_integration_id  (user_integration_id)
#

class DirectoryProlongation < ActiveRecord::Base
  attr_accessor :skip_expiration_management, :period, :invitation_crm_id

  belongs_to :user_integration, -> { with_deleted }
  belongs_to :user, -> { with_deleted }
  has_one :received_invitation, through: :user_integration

  validates :user_integration,    presence: true
  validates :expiration_date_new, presence: true
  validates :invitation_crm_id,   presence: true, on: :create, if: :user_integration_needs_crm_id?

  before_validation do
    self.expiration_date_old   = user_integration.directory_expiration_date
    self.expiration_date_new ||= [expiration_date_old, Date.today].max + period
  end

  after_create do
    if user_integration_needs_crm_id?
      received_invitation.update_attributes(crm_id: invitation_crm_id)
    end

    unless skip_expiration_management
      user_integration.update_attributes(directory_expiration_date: expiration_date_new)
      DirectoryProlongWorker.perform_async(id)
    end
  end

  def user_integration_needs_crm_id?
    return false unless ENV['INVITATION_FORCE_CRM_ID']
    received_invitation.present? && received_invitation.crm_id.blank?
  end

  def period
    @period || 1.month
  end
end
