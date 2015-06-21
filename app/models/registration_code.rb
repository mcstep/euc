# == Schema Information
#
# Table name: registration_codes
#
#  id                  :integer          not null, primary key
#  user_role           :integer          default(0), not null
#  user_validity       :integer          default(30), not null
#  code                :string           not null
#  total_registrations :integer          default(0), not null
#  registrations_used  :integer          default(0), not null
#  valid_from          :date
#  valid_to            :date
#  deleted_at          :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_registration_codes_on_deleted_at  (deleted_at)
#

class RegistrationCode < ActiveRecord::Base
  acts_as_paranoid

  has_many :users

  enum user_role: User::ROLES

  validates :user_validity, presence: true, numericality: { greater_than: 0 }
  validates :total_registrations, presence: true, numericality: { greater_than: 0 }

  before_create do
    self.code = Digest::SHA1.hexdigest([Time.now, rand].join)
  end
end
