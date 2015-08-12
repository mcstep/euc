# == Schema Information
#
# Table name: registration_codes
#
#  id                  :integer          not null, primary key
#  user_role           :integer          default(0), not null
#  user_validity       :integer          default(30), not null
#  code                :string           not null
#  total_registrations :integer          default(0), not null
#  valid_from          :date
#  valid_to            :date
#  deleted_at          :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  profile_id          :integer
#
# Indexes
#
#  index_registration_codes_on_deleted_at  (deleted_at)
#

class RegistrationCode < ActiveRecord::Base
  acts_as_paranoid

  has_many :users
  belongs_to :profile, -> { with_deleted }

  enum user_role: User::ROLES

  scope :actual, lambda{
    where("total_registrations > 0").
    where("valid_from IS NULL OR valid_from <= ?", Date.today).
    where("valid_to IS NULL OR valid_to >= ?", Date.today)
  }

  validates :code, uniqueness: { scope: :deleted_at }
  validates :user_validity, presence: true, numericality: { greater_than: 0 }
  validates :total_registrations, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :profile, presence: true

  before_save do
    self.code = Digest::SHA1.hexdigest([Time.now, rand].join)[0...8] if code.blank?
  end
end
