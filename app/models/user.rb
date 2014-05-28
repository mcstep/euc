class User < ActiveRecord::Base
  validates_presence_of :username
  validates_uniqueness_of :username

  def self.authenticate(username, password)
    user = find_by_username(username)
    if user
      user
    else
      nil
    end
  end

  has_many :sent_invitations, :class_name => 'Invitation', :foreign_key => 'sender_id'
  belongs_to :invitation

  before_create :set_invitation_limit

private

  def set_invitation_limit
    self.invitation_limit = 5
  end

end
