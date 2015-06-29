# == Schema Information
#
# Table name: invitations
#
#  id              :integer          not null, primary key
#  from_user_id    :integer
#  to_user_id      :integer
#  sent_at         :datetime
#  status          :integer          default(0), not null
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

  belongs_to :from_user, class_name: 'User'
  belongs_to :to_user,   class_name: 'User'

  as_enum :status, {pending: 0, active: 1, expired: 2, declined: 3}

  accepts_nested_attributes_for :to_user

  validates :from_user, presence: true
  validates :to_user, presence: true, uniqueness: {scope: :from_user_id}
  validates :to_user_id, inclusion: {in: [nil]}, on: :create

  before_validation do
    to_user.profile_id = from_user.profile_id if to_user
  end

  after_create do
    from_user.invitations_used += 1
    from_user.save!
  end

  def self.from(user)
    invitation = Invitation.new(from_user: user)
    invitation.build_to_user
    invitation.to_user.user_integrations = user.profile.profile_integrations.map(&:to_user_integration)
    invitation
  end
end
