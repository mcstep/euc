# == Schema Information
#
# Table name: google_apps_instances
#
#  id               :integer          not null, primary key
#  group_name       :string
#  group_region     :string
#  key_base64       :text
#  key_password     :string
#  initial_password :string
#  service_account  :string
#  act_on_behalf    :string
#  deleted_at       :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_google_apps_instances_on_deleted_at  (deleted_at)
#

class GoogleAppsInstance < ActiveRecord::Base
  acts_as_paranoid

  validates :key_base64, presence: true
  validates :initial_password, presence: true
  validates :service_account, presence: true
  validates :act_on_behalf, presence: true
  validates :group_region, presence: true, if: lambda{ group_name.present? }

  def key=(value)
    self.key_base64 = Base64.encode64(value)
  end

  def key
    Base64.decode64(key_base64) if key_base64.present?
  end

  def key_file
    file = Tempfile.new('google_apps_key')
    file.binmode
    file.write(key)
    file.rewind
    file.path
  end
end
