# == Schema Information
#
# Table name: customers
#
#  id         :integer          not null, primary key
#  company_id :integer
#  name       :string
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_customers_on_company_id  (company_id)
#  index_customers_on_deleted_at  (deleted_at)
#

class Customer < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :company, -> { with_deleted }

  validates :company, presence: true
  validates :name,    presence: true
end
