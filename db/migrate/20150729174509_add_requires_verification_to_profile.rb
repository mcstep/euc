class AddRequiresVerificationToProfile < ActiveRecord::Migration
  def change
    change_table :profiles do |t|
      t.boolean :requires_verification,   null: false, default: false
    end
  end
end
