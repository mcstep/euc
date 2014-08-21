class AddEulaAcceptDateToUsers < ActiveRecord::Migration
  def change
    add_column :users, :eula_accept_date, :datetime
  end
end
