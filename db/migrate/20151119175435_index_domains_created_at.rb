class IndexDomainsCreatedAt < ActiveRecord::Migration
  def change
    add_index :domains, :created_at
  end
end
