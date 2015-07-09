class Upgrade::Domain < ActiveRecord::Base
  self.table_name = "domains"

  enum status: [:active, :inactive]
end
