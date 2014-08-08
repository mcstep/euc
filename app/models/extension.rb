class Extension < ActiveRecord::Base
  belongs_to :extendor, :class_name => 'User', :foreign_key => 'extended_by'
end
