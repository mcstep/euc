class RemoveEulaAcceptDateFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :eula_accept_date, :datetime
  end
end
