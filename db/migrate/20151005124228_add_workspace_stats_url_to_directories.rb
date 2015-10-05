class AddWorkspaceStatsUrlToDirectories < ActiveRecord::Migration
  def change
    add_column :directories, :workspace_stats_url, :string
    rename_column :directories, :stats_url, :horizon_stats_url
  end
end
