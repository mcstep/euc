# == Schema Information
#
# Table name: user_integrations
#
#  id                        :integer          not null, primary key
#  user_id                   :integer
#  integration_id            :integer
#  directory_username        :string
#  directory_status          :integer
#  authentication_priority   :integer          default(0), not null
#  horizon_air_status        :integer          default(0), not null
#  horizon_workspace_status  :integer          default(0), not null
#  horizon_rds_status        :integer          default(0), not null
#  horizon_view_status       :integer          default(0), not null
#  airwatch_status           :integer          default(0), not null
#  office365_status          :integer          default(0), not null
#  google_apps_status        :integer          default(0), not null
#  directory_expiration_date :date             not null
#  airwatch_user_id          :integer
#  airwatch_group_id         :integer
#  deleted_at                :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_user_integrations_on_airwatch_group_id  (airwatch_group_id)
#  index_user_integrations_on_airwatch_user_id   (airwatch_user_id)
#  index_user_integrations_on_deleted_at         (deleted_at)
#  index_user_integrations_on_integration_id     (integration_id)
#  index_user_integrations_on_user_id            (user_id)
#

class UserIntegration < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user
  belongs_to :integration
  belongs_to :airwatch_group

  has_many :directory_prolongations

  statuses = {disabled: -1, not_provisioned: 0, provisioned: 1}
  Integration::SERVICES.each do |s|
    as_enum :"#{s}_status", {disabled: -1, not_provisioned: 0, provisioned: 1}, prefix: s
  end

  validates :user, presence: true
  validates :integration, presence: true
  validates :directory_username, presence: true
  validates :directory_expiration_date, presence: true

  Integration::SERVICES.each do |s|
    define_method :"#{s}_disabled" do
      self["#{s}_status"] < 0
    end

    define_method :"#{s}_disabled=" do |value|
      if ActiveRecord::Type::Boolean.new.type_cast_from_database(value)
        send :"#{s}_disabled!"
      else
        send :"#{s}_not_provisioned!" if send(:"#{s}_disabled?")
      end
    end
  end

  def adapt(user_integration)
    if user_integration.authentication_priority.present?
      self.authentication_priority = user_integration.authentication_priority
    end

    Integration::SERVICES.each do |s|
      send :"#{s}_disabled=", user_integration.send(:"#{s}_disabled")
    end
  end

  def directory
    integration.directory
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
end
