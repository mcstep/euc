# == Schema Information
#
# Table name: domains
#
#  id         :integer          not null, primary key
#  company_id :integer
#  profile_id :integer
#  name       :string
#  status     :integer          default(0), not null
#  limit      :integer
#  user_role  :integer          default(0), not null
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_domains_on_company_id  (company_id)
#  index_domains_on_deleted_at  (deleted_at)
#  index_domains_on_profile_id  (profile_id)
#

class Domain < ActiveRecord::Base
  include CompanyHolder

  belongs_to :profile

  as_enum :status, {active: 0, inactive: 1}
  as_enum :user_role, User::ROLES

  before_validation { name.downcase! }

  validates :name, uniqueness: true, hostname: true
  validates :profile, presence: true
end
