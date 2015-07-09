class Upgrade::Account < ActiveRecord::Base
  self.table_name = "old.accounts"

  enum account_source: [:trygrid]
end
