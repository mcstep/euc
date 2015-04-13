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

  mount_uploader :avatar, AvatarUploader

  enum role: [:user, :vip, :admin]

  before_create :set_invitation_limit
  after_initialize :set_default_role, :if => :new_record?
  before_save :to_lower
  before_save :destroy_previous_avatar

  def set_default_role
    self.role ||= :user
  end

  # Heroku has a read-only /public/uploads dir
  def cache_dir
    "#{Rails.root}/tmp/uploads"
  end

private
  def set_invitation_limit
    self.invitation_limit = 5
    #TODO: Potentially set total_invitations to a configurable global value
  end

  def to_lower
    self.email = self.email.downcase
    self.username = self.username.downcase
  end

  def destroy_previous_avatar
    self.avatar_was.remove! unless self.avatar_was.blank?
  end
end
