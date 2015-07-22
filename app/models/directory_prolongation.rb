# == Schema Information
#
# Table name: directory_prolongations
#
#  id                  :integer          not null, primary key
#  user_integration_id :integer
#  user_id             :integer
#  reason              :string
#  expiration_date_old :date
#  expiration_date_new :date
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_directory_prolongations_on_user_id              (user_id)
#  index_directory_prolongations_on_user_integration_id  (user_integration_id)
#

class DirectoryProlongation < ActiveRecord::Base
  belongs_to :user_integration
  belongs_to :user

  validates :user_integration,    presence: true
  validates :expiration_date_new, presence: true
  validates :expiration_date_old, presence: true

  after_create do
    user_integration.integration.directory.prolong(user_integration.username, expiration_date_new)
    DirectoryProlongationWorker.perform_async(id)
  end
end
