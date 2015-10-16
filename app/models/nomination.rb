# == Schema Information
#
# Table name: nominations
#
#  id            :integer          not null, primary key
#  user_id       :integer          not null
#  company_name  :string           not null
#  domain        :string           not null
#  status        :integer          default(0), not null
#  partner_type  :integer          default(0), not null
#  contact_name  :string           not null
#  contact_email :string           not null
#  contact_phone :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_nominations_on_user_id  (user_id)
#

class Nomination < ActiveRecord::Base
  attr_accessor :profile_id, :approval

  belongs_to :user

  as_enum :partner_type, {none: 0, professional: 1, enterprise: 2, premier: 3}
  as_enum :status, {nominated: 0, approved: 1, declined: 2}

  validates :user, presence: true
  validates :company_name, presence: true
  validates :contact_name, presence: true
  validates :contact_email, presence: true
  validates :domain, presence: true, uniqueness: true, hostname: true
  validates :profile_id, presence: true, if: :approval

  def decline!
    self.status = :declined
    save!
  end

  def approve!
    transaction do
      self.status = :approved
      save!

      Domain.create!(name: domain, company_name: company_name, profile_id: profile_id)
    end
  end
end
