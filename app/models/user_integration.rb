# == Schema Information
#
# Table name: user_integrations
#
#  id                        :integer          not null, primary key
#  user_id                   :integer
#  integration_id            :integer
#  username                  :string
#  directory_expiration_date :date             not null
#  directory_status          :integer          default(0), not null
#  horizon_air_status        :integer          default(0), not null
#  horizon_rds_status        :integer          default(0), not null
#  horizon_view_status       :integer          default(0), not null
#  airwatch_status           :integer          default(0), not null
#  office365_status          :integer          default(0), not null
#  google_apps_status        :integer          default(0), not null
#  airwatch_user_id          :integer
#  airwatch_admin_user_id    :integer
#  airwatch_group_id         :integer
#  deleted_at                :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
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

  attr_accessor :disable_provisioning, :password

  belongs_to :user, inverse_of: :user_integrations
  belongs_to :integration
  belongs_to :airwatch_group

  has_many :directory_prolongations

  # Integration::SERVICES.each do |service|
  #   scope :"with_#{service}", lambda{
  #     joins(:integration).where("#{service}_status != -1 AND integrations.#{service}_instance_id IS NOT NULL")
  #   }
  # end

  after_commit    :init_provisioning,  on: :create
  after_commit    :apply_provisioning, on: :update
  before_destroy  :drop_provisioning

  as_enum :directory_status, {
    provisioning: 0,
    account_created: 1,
    provisioned:     2
  }, prefix: 'directory'

  typical_service_statuses = {
    revoked: -4,
    available: -3,
    revoking: -2,
    disabled: -1,
    provisioning: 0,
    provisioned: 1
  }

  as_enum :airwatch_status, typical_service_statuses.merge(not_approved: 2), prefix: 'airwatch'

  Integration::SERVICES.each do |s|
    next if s == 'airwatch'
    as_enum :"#{s}_status", typical_service_statuses, prefix: s
  end

  validates :user, presence: true
  validates :integration, presence: true
  validates :username, presence: true
  validates :directory_expiration_date, presence: true

  Integration::SERVICES.each do |s|
    define_method "#{s}_disabled" do
      self["#{s}_status"] < 0
    end

    define_method "#{s}_disabled=" do |value|
      value = ActiveRecord::Type::Boolean.new.type_cast_from_database(value)
      return if value == send("#{s}_disabled")

      if value
        send(s).disable
      else
        send(s).enable
      end
    end
  end

  def applying?
    (Integration::SERVICES.map{|s| send("#{s}_status")} & [:provisioning, :revoking]).any?
  end

  def authentication_priority
    user.profile.profile_integrations
      .find{|x| x.integration_id == integration_id}.try(:authentication_priority)
  end

  def directory
    integration.directory
  end

  def airwatch_group_name
    "#{integration.airwatch_instance_id}-#{user.company_name}".downcase.gsub(/[^a-zA-Z0-9]/, '-')[0...20]
  end

  def replace_status(service, value)
    @disable_provisioning = true
    update_attribute("#{service}_status", value)
    @disable_provisioning = false
  end

  def init_provisioning
    return if @disable_provisioning

    Integration::SERVICES.select{|s| send("#{s}_status") == :provisioning}.each do |s|
      ProvisionerWorker[s].provision_async(id)
    end
  end

  def apply_provisioning
    return if @disable_provisioning

    Integration::SERVICES.each do |s|
      if change = previous_changes["#{s}_status"]
        from   = UserIntegration.send("#{s}_statuses").key(change[0])
        to     = change[1]

        if to == :revoking
          ProvisionerWorker[s].revoke_async(id)
        elsif to == :provisioning && from == :revoked
          ProvisionerWorker[s].resume_async(id)
        elsif to == :provisioning
          ProvisionerWorker[s].provision_async(id)
        end
      end
    end
  end

  def drop_provisioning
    return if @disable_provisioning

    Integration::SERVICES.each do |s|
      status = send("#{s}_status")

      if status == :provisioned
        ProvisionerWorker[s].deprovision_async(id)
      elsif status == :revoked
        ProvisionerWorker[s].cleanup_async(id)
      end
    end
  end
end
