if Rails.env.development?
  ActiveRecord::Base.transaction do
    (ActiveRecord::Base.connection.tables - ['schema_migrations']).each do |table|
        table.classify.constantize.delete_all
    end
  end
end