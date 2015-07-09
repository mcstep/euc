class Upgrade::Extension < ActiveRecord::Base
  self.table_name = "old.extensions"

  belongs_to :extendor, class_name: 'Upgrade::User', foreign_key: 'extended_by'
end
