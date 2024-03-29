# == Schema Information
#
# Table name: users
#
#  id                            :integer          not null, primary key
#  company_id                    :integer
#  profile_id                    :integer
#  registration_code_id          :integer
#  authentication_integration_id :integer
#  email                         :string           not null
#  first_name                    :string
#  last_name                     :string
#  avatar                        :string
#  country_code                  :string
#  phone                         :string
#  role                          :integer          default(0), not null
#  status                        :integer          default(0), not null
#  job_title                     :string
#  invitations_used              :integer          default(0), not null
#  total_invitations             :integer          default(5), not null
#  home_region                   :string
#  airwatch_eula_accept_date     :date
#  last_authorized_at            :datetime
#  deleted_at                    :datetime
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  verification_token            :string
#  can_edit_services             :boolean          default(FALSE), not null
#  can_see_reports               :boolean          default(FALSE), not null
#  can_see_opportunities         :boolean          default(FALSE), not null
#  desired_password              :string
#  domain_id                     :integer
#
# Indexes
#
#  index_users_on_authentication_integration_id  (authentication_integration_id)
#  index_users_on_company_id                     (company_id)
#  index_users_on_created_at                     (created_at)
#  index_users_on_deleted_at                     (deleted_at)
#  index_users_on_email                          (email)
#  index_users_on_profile_id                     (profile_id)
#  index_users_on_registration_code_id           (registration_code_id)
#

class Upgrade::User < ActiveRecord::Base
  self.table_name = Upgrade.table('users')
  establish_connection :import

  belongs_to :invitation, -> { with_deleted }
  has_many :sent_invitations, class_name: 'Upgrade::Invitation', foreign_key: 'sender_id'
  has_many :extensions,  class_name: 'Upgrade::Extension', foreign_key: 'extended_by'
end
