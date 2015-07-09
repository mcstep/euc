class Upgrade::RegCode < ActiveRecord::Base
  self.table_name = "old.reg_codes"

  has_many :invitations
end
