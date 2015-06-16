class Invitation < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :sender, :class_name => 'User'
  has_one :recipient, :class_name => 'User'

  validates_presence_of :recipient_email, :recipient_firstname, :recipient_lastname
  validate :recipient_is_not_registered, :on => :create
  validate :sender_has_invitations, :if => :sender, :on => :create

  before_create :generate_token
  before_create :decrement_sender_count, :if => :sender

  validates_uniqueness_of :recipient_email, :case_sensitive => false, :scope => [:deleted_at]
  #validates_uniqueness_of :recipient_email
  #validates_uniqueness_of :recipient_email, :scope => [:invitation_status]
  enum invitation_status: [:pending, :active, :expired, :declined]

  before_save :to_lower

  paginates_per 150

private

  def recipient_is_not_registered
    errors.add :recipient_email, 'is already registered' if Invitation.find_by_recipient_email(recipient_email)
  end

  def sender_has_invitations
    invites_remaining = sender.total_invitations - sender.invitations_used
    unless invites_remaining > 0
      errors.add_to_base 'You have reached your limit of invitations to send.'
    end
  end

  def generate_token
    self.token = Digest::SHA1.hexdigest([Time.now, rand].join)
  end

  def decrement_sender_count
    sender.decrement! :invitation_limit unless !self.sender.blank? && self.sender.admin?
    sender.increment! :invitations_used unless !self.sender.blank? && self.sender.admin?
  end

  def to_lower
    self.recipient_email = self.recipient_email.downcase unless self.recipient_email.blank?
    self.recipient_username = self.recipient_username.downcase unless self.recipient_username.blank?
  end
end
