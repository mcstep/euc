# == Schema Information
#
# Table name: accounts
#
#  id              :integer          not null, primary key
#  first_name      :string(255)
#  last_name       :string(255)
#  email           :string(255)
#  expiration_date :datetime
#  username        :string(255)
#  company         :string(255)
#  job_title       :string(255)
#  account_source  :integer
#  created_at      :datetime
#  updated_at      :datetime
#  deleted_at      :datetime
#  home_region     :string(255)
#  uuid            :string(255)
#  country_code    :string(255)
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
