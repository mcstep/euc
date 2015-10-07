class UnifyUrls < ActiveRecord::Migration
  def change
    remove_column :directories, :workspace_stats_url, :string
    rename_column :directories, :horizon_stats_url, :stats_url
  end
end
