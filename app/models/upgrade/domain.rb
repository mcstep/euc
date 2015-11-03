# == Schema Information
#
# Table name: domains
#
#  id                :integer          not null, primary key
#  company_id        :integer
#  profile_id        :integer
#  name              :string
#  status            :integer          default(0), not null
#  limit             :integer
#  user_role         :integer          default(0), not null
#  deleted_at        :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  total_invitations :integer
#  nomination_id     :integer
#  user_validity     :integer
#
# Indexes
#
#  index_domains_on_company_id  (company_id)
#  index_domains_on_deleted_at  (deleted_at)
#  index_domains_on_profile_id  (profile_id)
#

class Upgrade::Domain < ActiveRecord::Base
  self.table_name = Upgrade.table('domains')
  establish_connection :import

  enum status: [:active, :inactive]
end
