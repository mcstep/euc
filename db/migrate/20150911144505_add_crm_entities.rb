class AddCrmEntities < ActiveRecord::Migration
  def change
    add_column :companies, :crm_kind, :integer, null: false, default: 0
    add_column :companies, :salesforce_opportunity_instance_id, :integer
    add_column :companies, :salesforce_dealreg_instance_id, :integer

    add_column :invitations, :crm_kind, :integer
    add_column :invitations, :crm_id, :string
    add_column :invitations, :crm_data, :text
    add_column :invitations, :crm_fetch_error, :boolean, null: false, default: false

    add_column :salesforce_instances, :host, :string
  end
end
