# == Schema Information
#
# Table name: user_integrations
#
#  id                              :integer          not null, primary key
#  user_id                         :integer
#  integration_id                  :integer
#  username                        :string
#  directory_expiration_date       :date             not null
#  directory_status                :integer          default(0), not null
#  horizon_air_status              :integer          default(0), not null
#  horizon_rds_status              :integer          default(0), not null
#  horizon_view_status             :integer          default(0), not null
#  airwatch_status                 :integer          default(0), not null
#  office365_status                :integer          default(0), not null
#  google_apps_status              :integer          default(0), not null
#  airwatch_user_id                :integer
#  airwatch_admin_user_id          :integer
#  airwatch_group_id               :integer
#  deleted_at                      :datetime
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  blue_jeans_status               :integer          default(0), not null
#  blue_jeans_user_id              :integer
#  salesforce_status               :integer          default(0), not null
#  salesforce_user_id              :string
#  blue_jeans_removal_requested_at :datetime
#  prohibited_services             :string           default([]), not null
#
# Indexes
#
#  index_user_integrations_on_airwatch_admin_user_id      (airwatch_admin_user_id)
#  index_user_integrations_on_airwatch_group_id           (airwatch_group_id)
#  index_user_integrations_on_airwatch_user_id            (airwatch_user_id)
#  index_user_integrations_on_deleted_at                  (deleted_at)
#  index_user_integrations_on_integration_id              (integration_id)
#  index_user_integrations_on_user_id                     (user_id)
#  index_user_integrations_on_user_id_and_integration_id  (user_id,integration_id) UNIQUE
#

class UserIntegration < ActiveRecord::Base
  include StateMachines

  acts_as_paranoid

  attr_accessor :skip_provisioning, :password

  belongs_to :user, -> { with_deleted }, inverse_of: :user_integrations
  belongs_to :integration, -> { with_deleted }
  belongs_to :airwatch_group, -> { with_deleted }

  has_many :directory_prolongations

  unless ActiveRecord::Base.connection_config[:adapter] == 'postgresql'
    serialize :prohibited_services
  end

  after_commit    :init_provisioning,  on: :create
  after_commit    :apply_provisioning, on: :update
  after_destroy   :drop_provisioning

  as_enum :directory_status, {
    provisioning: 0,
    account_created: 1,
    provisioned:     2
  }, prefix: 'directory'

  Integration::SERVICES.each do |s|
    as_enum :"#{s}_status", {
      deprovisioning: -5,
      revoked: -4,
      revoking: -2,
      deprovisioned: -1,
      provisioning: 0,
      provisioned: 1,
      not_approved: 2
    }, prefix: s
  end

  validates :user, presence: true
  validates :integration, presence: true
  validates :directory_expiration_date, presence: true

  Integration::SERVICES.each do |s|
    define_method "#{s}_applying?" do
      self[s].applying?
    end

    define_method "#{s}_disabled?" do
      self[s].disabled?
    end

    define_method "prohibit_#{s}" do
      self.prohibited_services.include?(s.to_s)
    end

    define_method "prohibit_#{s}=" do |value|
      value = ActiveRecord::Type::Boolean.new.type_cast_from_database(value) 

      if value
        send(s).prohibit
        self.prohibited_services += [s.to_s]
        self.prohibited_services.uniq!
      else
        self.prohibited_services -= [s.to_s]
      end
    end
  end

  def [](*args)
    return send(args[0]) if Integration::SERVICES.include?(args[0])
    super
  end

  def email
    "#{username}@#{integration.domain}"
  end

  def airwatch_email
    if integration.airwatch_instance.use_templates
      "#{username}@#{AirwatchTemplate.produce(self).data['enrollmentEmailDomain']}"
    else
      email
    end
  end

  def applying?
    Integration::SERVICES.any?{|s| send "#{s}_applying?"}
  end

  def authentication_priority
    user.profile.profile_integrations
      .find{|x| x.integration_id == integration_id}.try(:authentication_priority)
  end

  def directory
    integration.directory
  end

  def airwatch_group_name
    user.email.split("@").last.gsub('.','-')[0...20]
  end

  def replace_status(service, value)
    @skip_provisioning = true
    update_attribute("#{service}_status", value)
    @skip_provisioning = false
  end

  def init_provisioning
    return if @skip_provisioning

    Integration::SERVICES.select{|s| send("#{s}_status") == :provisioning}.each do |s|
      ProvisionerWorker[s].provision_async(id)
    end
  end

  def apply_provisioning
    return if @skip_provisioning

    Integration::SERVICES.each do |s|
      if change = previous_changes["#{s}_status"]
        from   = UserIntegration.send("#{s}_statuses").key(change[0])
        to     = change[1]

        if to == :revoking
          ProvisionerWorker[s].revoke_async(id)
        elsif to == :deprovisioning
          ProvisionerWorker[s].deprovision_async(id)
        elsif to == :provisioning && from == :revoked
          ProvisionerWorker[s].resume_async(id)
        elsif to == :provisioning
          ProvisionerWorker[s].provision_async(id)
        end
      end
    end
  end

  def drop_provisioning
    return if @skip_provisioning
    ProvisionerWorker.cleanup_async(id)
  end


  def airwatch_template
    AirwatchTemplate.produce(self)
  end
end
