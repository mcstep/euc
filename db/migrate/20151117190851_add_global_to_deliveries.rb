class AddGlobalToDeliveries < ActiveRecord::Migration
  def change
    add_column :deliveries, :global, :boolean, null: false, default: true
  end
end
