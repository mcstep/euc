class CreateAirwatchTemplates < ActiveRecord::Migration
  def change
    create_table :airwatch_templates do |t|
      t.belongs_to  :airwatch_instance
      t.string      :domain
      t.text        :data

      t.datetime    :deleted_at,    index: true
      t.timestamps                  null: false
    end

    change_table :airwatch_instances do |t|
      t.string      :templates_api_url
      t.string      :templates_token
      t.boolean     :use_templates, null: false, default: false
    end
  end
end
