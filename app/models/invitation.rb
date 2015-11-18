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
#  index_invitations_on_crm_kind      (crm_kind)
#  index_invitations_on_deleted_at    (deleted_at)
#  index_invitations_on_from_user_id  (from_user_id)
#  index_invitations_on_to_user_id    (to_user_id)
#

class Invitation < ActiveRecord::Base
  include StatsProvider

  acts_as_paranoid

  attr_accessor :skip_points_management

  as_enum :crm_kind, CrmConfigurator.kinds
  serialize :crm_data

  belongs_to :from_user, -> { with_deleted }, class_name: 'User'
  belongs_to :to_user, -> { with_deleted }, class_name: 'User', inverse_of: :received_invitation

  accepts_nested_attributes_for :to_user

  validates :from_user, presence: true
  validates :to_user, presence: true, uniqueness: { scope: [:from_user_id, :deleted_at] }
  validates :from_user_id, presence: true, on: :create

  validate do
    if crm_specified? && from_user && instance = from_user.company.crm_instance(crm_kind)
      unless instance.validate_crm_data(crm_kind, crm_id)
        errors.add :crm_id, :invalid
      end
    end
  end

  validate(on: :create) do
    unless skip_points_management
      errors.add :from_user, :invalid unless from_user.invitations_left > 0
    end
  end

  after_commit    :refresh_crm_data, on: :create, if: :crm_specified?
  after_create    :use_invitation_point!
  after_destroy   :free_invitation_point!

  delegate :id, to: :from_user, prefix: true

  def self.from(user)
    invitation = Invitation.new(from_user: user)
    invitation.build_to_user
    invitation.to_user.user_integrations = user.profile.profile_integrations.map(&:to_user_integration)
    invitation
  end

  def use_invitation_point!
    return if skip_points_management
    from_user.invitations_used += 1
    from_user.save!
  end
 
  def free_invitation_point!
    return if skip_points_management
    from_user.invitations_used -= 1
    from_user.save!
  end

  def crm_specified?
    crm_id.present? && crm_kind.present?
  end

  def user_validity
    crm_specified? ? 30 : (ENV['TEST_USER_VALIDITY'] || 1).to_i
  end

  def refresh_crm_data
    InvitationFetchCrmWorker.perform_async(id)
  end
end
