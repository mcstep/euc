class AddEulaAcceptDateToInvitation < ActiveRecord::Migration
  def change
    add_column :invitations, :eula_accept_date, :datetime
  end
end
