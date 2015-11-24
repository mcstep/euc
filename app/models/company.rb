# == Schema Information
#
# Table name: companies
#
#  id                                 :integer          not null, primary key
#  name                               :string
#  deleted_at                         :datetime
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  crm_kind                           :integer          default(0), not null
#  salesforce_opportunity_instance_id :integer
#  salesforce_dealreg_instance_id     :integer
#  type                               :string
#
# Indexes
#
#  index_companies_on_deleted_at  (deleted_at)
#

class Company < ActiveRecord::Base
  include CrmConfigurator

  self.inheritance_column = :hell_no

  TYPES = %w(health finance gov edu retail engineer other)
  
  acts_as_paranoid

  validates :name, presence: true, uniqueness: { scope: :deleted_at }
  validates :type, inclusion: { in: TYPES, allow_blank: true }

  scope :named, lambda{|name| where("LOWER(name) = ?", name.downcase) }

  has_many :users
  has_many :sent_invitations, through: :users

  def potential_seats_invited_by(user)
    user.sent_invitations.select{|x| x.to_user.company_id == id}.map(&:potential_seats).compact.inject(:+)
  end
end
