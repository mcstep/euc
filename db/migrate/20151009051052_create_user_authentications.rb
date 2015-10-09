class CreateUserAuthentications < ActiveRecord::Migration
  def change
    create_table :user_authentications do |t|
      t.belongs_to  :user
      t.string      :ip
      t.boolean     :successful
      t.timestamps               null: false
    end
  end
end
