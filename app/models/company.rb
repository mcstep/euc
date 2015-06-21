# == Schema Information
#
# Table name: companies
#
#  id         :integer          not null, primary key
#  name       :string
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_companies_on_deleted_at  (deleted_at)
#

class Company < ActiveRecord::Base
  acts_as_paranoid

  validates :name, presence: true, uniqueness: true

  scope :named, lambda{|name| where("LOWER(name) = ?", name.downcase) }

  def potential_seats_invited_by(user)
    user.sent_invitations.select{|x| x.to_user.company_id == id}.map(&:potential_seats).compact.inject(:+)
  end
end
