class Account < ActiveRecord::Base
 acts_as_paranoid
 enum account_source: [:trygrid]
end
