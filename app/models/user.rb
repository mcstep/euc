class User < ActiveRecord::Base
  validates_presence_of :username
  validates_uniqueness_of :username

  belongs_to :invitation

  def self.authenticate(username, password)
    user = find_by_username(username)
    if user
      user
    else
      nil
    end
  end

  def self.default_avatar_url
    ActionController::Base.helpers.image_path('default_avatar.png')
  end

  has_many :sent_invitations, :class_name => 'Invitation', :foreign_key => 'sender_id'
  belongs_to :invitation

  mount_uploader :avatar, AvatarUploader

  enum role: [:user, :vip, :admin]

  before_create :set_invitation_limit
  after_initialize :set_default_role, :if => :new_record?
  before_save :to_lower
  before_save :destroy_previous_avatar

  def first_name
    display_name.split(' ', 2).first
  end

  def last_name
    display_name.split(' ', 2).last
  end

  def set_default_role
    self.role ||= :user
  end

  def avatar_url
    if self.avatar.blank?
      self.class.default_avatar_url
    else
      Cloudinary::Utils.cloudinary_url(self.avatar, :width => 200, :height => 200, :crop => :thumb)
    end
  end

  def region
    Invitation.find(self.invitation_id).region;
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
    if self.avatar_changed? and self.avatar_was.instance_of? AvatarUploader
      self.avatar_was.remove!
    end
  end
end
