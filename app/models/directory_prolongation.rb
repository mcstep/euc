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
  belongs_to :user_integration, -> { with_deleted }
  belongs_to :user, -> { with_deleted }

  validates :user_integration,    presence: true
  validates :expiration_date_new, presence: true

  before_validation do
    self.expiration_date_old   = user_integration.directory_expiration_date
    self.expiration_date_new ||= [expiration_date_old, Date.today].max + 1.month
  end

  after_create do
    user_integration.update_attributes(directory_expiration_date: expiration_date_new)
    DirectoryProlongWorker.perform_async(id)
  end
end
