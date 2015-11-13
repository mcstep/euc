class AddSendNotificationToDirectoryProlongations < ActiveRecord::Migration
  def change
    add_column :directory_prolongations, :send_notification, :boolean, null: false, default: true
  end
end
