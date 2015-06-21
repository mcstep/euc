# == Schema Information
#
# Table name: partners
#
#  id                :integer          not null, primary key
#  company_id        :integer
#  vmware_partner_id :integer
#  contact_name      :string
#  contact_email     :string
#  contact_phone     :string
#  deleted_at        :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_partners_on_company_id  (company_id)
#  index_partners_on_deleted_at  (deleted_at)
#

class Partner < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :company
  belongs_to :vmware_partner

  validates :contact_name, presence: true
  validates :contact_email, presence: true
  validates :contact_phone, presence: true
end
