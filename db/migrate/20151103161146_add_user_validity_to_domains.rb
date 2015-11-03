class AddUserValidityToDomains < ActiveRecord::Migration
  def change
    add_column :domains, :user_validity, :integer
  end
end
