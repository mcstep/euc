class AddCompanyAndTitleToUsers < ActiveRecord::Migration
  def change
    add_column :users, :company, :string
    add_column :users, :title, :string
  end
end
