class AddPotentialSeatsToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :potential_seats, :integer
  end
end
