class Invitation < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :reg_code
  belongs_to :sender, :class_name => 'User'
  has_one :recipient, :class_name => 'User'

  enum invitation_status: [:pending, :active, :expired, :declined]

  validates_presence_of :recipient_email, :recipient_firstname, :recipient_lastname, :recipient_company, :recipient_title, :region
  validate :valid_reg_code, :if => :reg_code, :on => :create
  validate :sender_has_invitations, :if => :sender, :on => :create
  validate :valid_email_domain, :on => :create

  validates_uniqueness_of :recipient_email, :scope => [:deleted_at]
  validates_uniqueness_of :recipient_username, :allow_blank => true, :scope => [:deleted_at]

  before_validation :strip_whitespace

  before_create :set_defaults
  before_create :generate_token
  before_create :decrement_sender_count, :if => :sender

  paginates_per 150

private
  def valid_reg_code
    if reg_code.status != true || !(reg_code.valid_from..reg_code.valid_to).cover?(Time.now) || Invitation.where(reg_code_id: reg_code.id).count >= reg_code.registrations.to_i
      errors[:reg_code] << 'The registration code you entered is no longer valid.'
    end
  end

  def sender_has_invitations
    if sender.invitations_used >= sender.total_invitations
      errors[:base] << 'You have reached your limit of invitations to send.'
    end
  end

  def valid_email_domain
    if !recipient_email.blank?
      domain = Domain.find_by_name(recipient_email.split("@").last.downcase)

      if domain.nil? || domain.status != 'active'
        errors[:recipient_email] << "Your email domain is currently not supported for registrations."
      end
    end
  end

  def set_defaults
    if self.reg_code.nil?
      self.expires_at = (Time.now + 1.year)
    else
      self.expires_at = (Time.now + reg_code.account_validity.days)
    end

    self.airwatch_trial    = true if self.airwatch_trial.nil?
    self.google_apps_trial = true if self.google_apps_trial.nil?
  end

  def generate_token
    self.token = Digest::SHA1.hexdigest([Time.now, rand].join)
  end

  def decrement_sender_count
    sender.decrement! :invitation_limit unless !self.sender.blank? && self.sender.admin?
    sender.increment! :invitations_used unless !self.sender.blank? && self.sender.admin?
  end

  def strip_whitespace
    self.recipient_email     = self.recipient_email.strip.downcase    unless self.recipient_email.nil?
    self.recipient_firstname = self.recipient_firstname.strip         unless self.recipient_firstname.nil?
    self.recipient_lastname  = self.recipient_lastname.strip          unless self.recipient_lastname.nil?
    self.recipient_username  = self.recipient_username.strip.downcase unless self.recipient_username.nil?
    self.recipient_company   = self.recipient_company.strip           unless self.recipient_company.nil?
    self.recipient_title     = self.recipient_title.strip             unless self.recipient_title.nil?
    self.region              = self.region.strip                      unless self.region.nil?
  end
end
