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

class Account < ActiveRecord::Base
  acts_as_paranoid
  enum account_source: [:trygrid]
end
