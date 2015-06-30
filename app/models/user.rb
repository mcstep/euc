# == Schema Information
#
# Table name: users
#
#  id                            :integer          not null, primary key
#  company_id                    :integer
#  profile_id                    :integer
#  registration_code_id          :integer
#  authentication_integration_id :integer
#  email                         :string           not null
#  first_name                    :string
#  last_name                     :string
#  avatar                        :string
#  country_code                  :string
#  phone                         :string
#  role                          :integer
#  status                        :integer
#  job_title                     :string
#  invitations_used              :integer          default(0), not null
#  total_invitations             :integer          default(5), not null
#  home_region                   :string
#  airwatch_eula_accept_date     :date
#  last_authorized_at            :datetime
#  deleted_at                    :datetime
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#
# Indexes
#
#  index_users_on_authentication_integration_id  (authentication_integration_id)
#  index_users_on_company_id                     (company_id)
#  index_users_on_deleted_at                     (deleted_at)
#  index_users_on_email                          (email)
#  index_users_on_profile_id                     (profile_id)
#  index_users_on_registration_code_id           (registration_code_id)
#

class User < ActiveRecord::Base
  include Authentication
  include IntegrationsDelegations

  acts_as_paranoid

  mount_uploader :avatar, AvatarUploader

  scope :expiring_soon, lambda {
    joins(:authentication_integration).where(
      'user_integrations.expires_at > ? and expires_at < ?', DateTime.now, DateTime.now + 72.hours
    )
  }

  scope :expired, lambda {
    joins(:authentication_integration).where(
      'user_integrations.expires_at < ?', DateTime.now - 24.hour # 24 hour grace period
    )
  }

  ROLES = {basic: 0, admin: 1, root: 2}
  REGIONS = %w(amer emea apac dldc)

  belongs_to :authentication_integration, class_name: "UserIntegration"
  belongs_to :company
  belongs_to :profile
  has_many :user_integrations, -> { includes(:directory_prolongations) }
  belongs_to :registration_code
  has_many :sent_invitations, -> { includes(:to_user) }, class_name: "Invitation", foreign_key: "from_user_id"
  has_one :received_invitation, class_name: "Invitation", foreign_key: "to_user_id"

  as_enum :role, ROLES

  accepts_nested_attributes_for :company
  accepts_nested_attributes_for :user_integrations

  delegate :can_assign_roles?, to: :policy

  before_save      :normalize!
  before_save      :cleanup_avatar!
  after_validation :normalize_errors
  after_create     { SignupWorker.perform_async(id) }
  after_destroy    { received_invitation.try(:free_invitation_point) }

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :company, presence: true
  validates :home_region, presence: true, inclusion: { in: REGIONS, allow_blank: true }
  validates :profile, presence: true

  validate do
    errors.add :invitations_used, :invalid if invitations_left < 0

    if authentication_integration_id && !user_integration_ids.include?(authentication_integration_id)
      errors.add :authentication_integration_id, :invalid 
    end
  end

  def policy
    UserPolicy.new(self)
  end

  def display_name
    "#{first_name} #{last_name}"
  end

  def display_name=(value)
    self.first_name, self.last_name = value.split(' ', 2)
  end

  def company_name
    company.try :name
  end

  def company_name=(value)
    if company = Company.named(value).first
      self.company_id = company.id
    else
      self.company_attributes = {name: value}
    end
  end

  def domain
    email.split("@", 2).last
  end

  def expiration_date
    authentication_integration.directory_expiration_date
  end

  def invited_users
    sent_invitations.map(&:to_user)
  end

  def expiring_invited_users
    invited_users.select{|x| x.expiration_date && x.expiration_date < Date.today + 1.month}
  end

  def invited_by
    received_invitation.try :from_user
  end

  def invitations_left
    total_invitations - invitations_used
  end

  def intitations_used_percents
    (100.0 * invitations_used / total_invitations).round
  end

  def has_airwatch?
    user_integrations.select{|ui| !ui.airwatch_disabled? && ui.integration.airwatch_instance}.any?
  end

  def avatar_url
    if avatar.blank?
      ActionController::Base.helpers.image_path('default_avatar.png')
    else
      Cloudinary::Utils.cloudinary_url(self.avatar, :width => 200, :height => 200, :crop => :thumb)
    end
  end

  def update_password(password=nil)
    authentication_integration.directory.update_password(
      authentication_integration.directory_username,
      password
    )
  end

  def normalize!
    email.downcase!
  end

  def normalize_errors
    errors[:company].each{|e| errors.add(:company_name, e)}
  end

  def cleanup_avatar!
    if self.avatar_changed? && self.avatar_was.instance_of?(AvatarUploader)
      self.avatar_was.remove!
    end
  end

  def update_from_ad!(data)
    {
      display_name: data['name'],
      job_title:    data['title'],
      email:        data['email'],
      company_name: data['company']
    }.each do |k, v|
      self.send("#{k}=", v) unless v.nil?
    end

    save!
  end

  def accept_airwatch_eula!
    self.airwatch_eula_accept_date = Date.today
    save!

    user_integrations.airwatch_not_approveds.each do |ui|
      ui.airwatch.approve
      ui.save!
    end
  end

  def expire!
    authentication_integration.directory.unregister(
      authentication_integration.directory_username
    )
    destroy!
  end
end
