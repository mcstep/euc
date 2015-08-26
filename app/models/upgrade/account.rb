# == Schema Information
#
# Table name: accounts
#
#  id              :integer          not null, primary key
#  first_name      :string
#  last_name       :string
#  email           :string
#  expiration_date :datetime
#  username        :string
#  company         :string
#  job_title       :string
#  account_source  :integer
#  created_at      :datetime
#  updated_at      :datetime
#  deleted_at      :datetime
#  home_region     :string
#  uuid            :string
#  country_code    :string
#
# Indexes
#
#  index_accounts_on_deleted_at  (deleted_at)
#

class Upgrade::Account < ActiveRecord::Base
  self.table_name = Upgrade.table('accounts')
  establish_connection :import

  enum account_source: [:trygrid]
end
