class AddUseSslToDirectories < ActiveRecord::Migration
  def change
    change_table :directories do |t|
      t.boolean     :use_ssl, null: false, default: false
    end
  end
end
