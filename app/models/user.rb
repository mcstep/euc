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

  enum role: [:user, :vip, :admin]
  after_initialize :set_default_role, :if => :new_record?

  before_save :to_lower

  def set_default_role
    self.role ||= :user
  end

private

  def set_invitation_limit
    self.invitation_limit = 5
  end

  def to_lower
    self.email = self.email.downcase
    self.username = self.username.downcase
  end

end
