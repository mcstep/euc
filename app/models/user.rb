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
#  verification_token            :string
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
  module Session extend ActiveSupport::Concern
    def self.get_user_id(request)
      request.cookie_jar.encrypted[ Rails.application.config.session_options[:key] ].try(:[], 'user_id')
    end

    def self.tag_user(user_id, &block)
      user_id = user_id.id if user_id.is_a?(User)
      user_id = get_user_id(user_id) if user_id.is_a?(ActionDispatch::Request)
      result  = '#' + (user_id || '?').to_s

      if block_given?
        Rails.logger.tagged(result){ yield }
      else
        return result
      end
    end

    class Constraint
      def initialize(policy_action)
        @policy_action = policy_action
      end

      def matches?(request)
        return true if Rails.env.development?

        user_id = User::Session.get_user_id(request)
        user_id && User.find(user_id).policy.send(@policy_action)
      end
    end

    def authenticate(password)
      return false unless data = authentication_integration.directory.authenticate(
        authentication_integration.username,
        password
      )

      {
        display_name: data['name'],
        job_title:    data['title'],
        email:        data['email'],
        company_name: data['company']
      }.each do |k, v|
        self.send("#{k}=", v) unless v.nil?
      end
      save!

      true
    end

    def policy
      UserPolicy.new(self)
    end
  end

  module IntegrationsDelegations extend ActiveSupport::Concern
    included do
      attr_accessor :integrations_disable_provisioning, :desired_password, :desired_password_confirmation

      before_validation :ensure_profile
      before_validation :setup_integrations, on: :create
      after_save        :setup_authentication

      validates :desired_password, confirmation: true, length: { minimum: 8 }, format: { with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)./, message: :invalid_password }, allow_blank: true
    end

    def integrations_username
      @username.blank? ? email.try(:split, '@').try(:first) : @username
    end

    def integrations_username=(value)
      @username = value
    end

    def integrations_expiration_date
      @expiration_date || Date.today + (root? ? 1.year : 1.month)
    end

    def integrations_expiration_date=(date)
      return if date.blank?
      date = date.to_date if date.respond_to?(:to_date)
      date = Date.parse(date) unless date.is_a?(Date)
      @expiration_date = date
    end

    def ensure_profile
      if profile.blank?
        if received_invitation.present?
          self.profile = received_invitation.from_user.profile
        elsif domain = Domain.where(name: email.split('@', 2).last).first
          self.profile = domain.profile
          self.role    = domain.user_role
        end
      end
    end

    def setup_integrations
      if profile.present?
        effective_integrations = profile.profile_integrations.to_a
        effective_integrations = effective_integrations.select{|ei| ei.allow_sharing} if received_invitation.present?
        effective_integrations.map!(&:to_user_integration)

        effective_integrations.each do |ei|
          ei.user                      = self
          ei.username                  = integrations_username
          ei.directory_expiration_date = integrations_expiration_date
          ei.disable_provisioning      = integrations_disable_provisioning

          if original = user_integrations.select{|ui| ui.integration_id == ei.integration_id}.first
            ei.adapt(original)
          end
        end

        self.user_integrations = effective_integrations
      end
    end

    def setup_authentication
      if authentication_integration.blank?
        self.authentication_integration = user_integrations.sort_by(&:authentication_priority).first
        save!
      end
    end
  end

  include Session
  include IntegrationsDelegations
  include CompanyHolder
  include RequestsLogger

  ##
  # Scopes
  ##
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

  def self.identified_by(handle)
    username, domain = handle.split('@', 2)
    joins(:authentication_integration => :integration).where("email = ? OR user_integrations.username = ? OR (user_integrations.username = ? AND integrations.domain = ?)", handle, handle, username, domain).first
  end

  ##
  # Constants
  ## 
  ROLES = {basic: 0, admin: 1, root: 2}
  REGIONS = %w(amer emea apac dldc)

  ##
  # Relations
  ##
  belongs_to :authentication_integration, class_name: "UserIntegration"
  belongs_to :profile
  has_many :user_integrations, -> { includes(:directory_prolongations) }, dependent: :destroy, inverse_of: :user
  belongs_to :registration_code
  has_many :sent_invitations, -> { includes(:to_user) }, class_name: "Invitation", foreign_key: "from_user_id"
  has_one :received_invitation, class_name: "Invitation", foreign_key: "to_user_id", inverse_of: :to_user

  ##
  # Extensions
  ##
  acts_as_paranoid
  mount_uploader :avatar, AvatarUploader
  accepts_nested_attributes_for :user_integrations

  as_enum :role, ROLES
  as_enum :status, {active: 0, verification_required: 1}

  ##
  # Validations
  ##
  before_save       :normalize!
  before_save       :cleanup_avatar!
  before_create     { self.status = :verification_required if profile.try(:requires_verification) }
  after_validation  :normalize_errors
  after_create      :use_registration_code_point!
  after_create      { SignupWorker.perform_async(id, desired_password) unless integrations_disable_provisioning }
  after_create      { send_verification! if verification_required? }
  after_destroy     { received_invitation.try(:free_invitation_point!) }

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :company, presence: true
  validates :job_title, presence: true
  validates :home_region, presence: true, inclusion: { in: REGIONS, allow_blank: true }
  validates :profile, presence: true

  validate do
    errors.add :invitations_used, :invalid if invitations_left < 0

    if user_integrations.blank?
      errors.add :authentication_integration_id, :invalid 
    end
  end

  ##
  # Helpers
  ##
  def provisioned?
    authentication_integration && authentication_integration.directory_status != :not_provisioned
  end

  def display_name
    "#{first_name} #{last_name}"
  end

  def display_name=(value)
    self.first_name, self.last_name = value.split(' ', 2)
  end

  def expiration_date
    authentication_integration.try :directory_expiration_date
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
      Cloudinary::Utils.cloudinary_url(self.avatar, width: 200, height: 200, crop: :thumb)
    end
  end

  ##
  # Modifiers
  ##
  def self.confirm!(email, token)
    return false unless attempt = where(email: email, verification_token: token).first

    attempt.status = :active
    attempt.save!

    attempt
  end

  def update_password(password=nil)
    authentication_integration.directory.update_password(
      authentication_integration.username,
      password
    )
  end

  def normalize!
    email.downcase!
  end

  def send_verification!
    transaction do
      self.verification_token = ReadableToken.generate
      self.save!
      VerificationDeliveryWorker.perform_async(id)
    end
  end

  def normalize_errors
    errors[:'company.name'].each{|e| errors.add(:company_name, e)}
    errors.add(:email, :incorrect_domain) if errors[:profile].any? && !email.blank?
  end

  def cleanup_avatar!
    if self.avatar_changed? && self.avatar_was.instance_of?(AvatarUploader)
      self.avatar_was.remove!
    end
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
      authentication_integration.username
    )
    destroy!
  end

  def use_registration_code_point!
    return if !registration_code
    registration_code.registrations_used += 1
    registration_code.save!
  end
end
