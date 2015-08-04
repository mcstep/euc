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

class Invitation < ActiveRecord::Base
  acts_as_paranoid

  attr_accessor :skip_points_management

  belongs_to :from_user, class_name: 'User'
  belongs_to :to_user,   class_name: 'User', inverse_of: :received_invitation

  accepts_nested_attributes_for :to_user

  validates :from_user, presence: true
  validates :to_user, presence: true, uniqueness: {scope: :from_user_id}
  validates :from_user_id, presence: true, on: :create

  before_create :use_invitation_point!
  after_destroy :free_invitation_point!

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
end
