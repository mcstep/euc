class CreateUserRequests < ActiveRecord::Migration
  def change
    create_table :user_requests do |t|
      t.string      :ip
      t.date        :date
      t.integer     :hour
      t.integer     :quantity
    end

    add_index :user_requests, [:date, :hour]
  end
end
