class AddStatsUrlToDirectories < ActiveRecord::Migration
  def change
    change_table :directories do |t|
      t.string    :stats_url
    end
  end
end
