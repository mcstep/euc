class AddForcedUserValidityToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :forced_user_validity, :integer
  end
end
