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
#  horizon_workspace_status  :integer          default(0), not null
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

  attr_accessor :disable_provisioning

  belongs_to :user, inverse_of: :user_integrations
  belongs_to :integration
  belongs_to :airwatch_group

  has_many :directory_prolongations

  # Integration::SERVICES.each do |service|
  #   scope :"with_#{service}", lambda{
  #     joins(:integration).where("#{service}_status != -1 AND integrations.#{service}_instance_id IS NOT NULL")
  #   }
  # end

  after_create    :init_provisioning
  after_update    :apply_provisioning
  before_destroy  :drop_provisioning

  as_enum :directory_status, {
    not_provisioned: 0,
    account_created: 1,
    profile_created: 2,
    groups_assigned: 3,
    provisioned:     4
  }, prefix: 'directory'

  as_enum :airwatch_status, {revoked: -2, disabled: -1, not_provisioned: 0, provisioned: 1, not_approved: 2}, prefix: 'airwatch'

  Integration::SERVICES.each do |s|
    next if s == 'airwatch'
    as_enum :"#{s}_status", {revoked: -2, disabled: -1, not_provisioned: 0, provisioned: 1}, prefix: s
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

  def adapt(user_integration)
    Integration::SERVICES.each do |s|
      send "#{s}_disabled=", user_integration.send("#{s}_disabled")
    end

    self
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

  def prolong!(user, date=nil)
    date   = Date.parse(date) if date.present? && !date.is_a?(Date)
    date ||= [directory_expiration_date, Date.today].max + 1.month

    DirectoryProlongation.create!(
      user_id:             user.id,
      user_integration_id: user_integration.id,
      expiration_date_old: user_integration.directory_expiration_date,
      expiration_date_new: date
    )
  end

  def replace_status(service, value)
    @disable_provisioning = true
    update_attribute("#{service}_status", value)
    @disable_provisioning = false
  end

  def init_provisioning
    return if @disable_provisioning

    Integration::SERVICES.select{|s| send("#{s}_status") == :not_provisioned}.each do |s|
      ProvisionerWorker[s].provision_async(id)
    end
  end

  def apply_provisioning
    return if @disable_provisioning

    Integration::SERVICES.each do |s|
      if change = changes["#{s}_status"]
        from   = send("#{s}_status_was")
        to     = change[1]

        if to == :revoked
          ProvisionerWorker[s].revoke_async(id)
        elsif to == :not_provisioned && from == :revoked
          ProvisionerWorker[s].resume_async(id)
        elsif to == :not_provisioned
          ProvisionerWorker[s].provision_async(id)
        end
      end
    end
  end

  def drop_provisioning
    return false if Integration::SERVICES.any?{|s| send("#{s}_status") == :not_provisioned}

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
