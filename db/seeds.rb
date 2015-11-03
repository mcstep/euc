if Rails.env.development?
  ActiveRecord::Base.transaction do
    (ActiveRecord::Base.connection.tables - ['schema_migrations', 'oauth_access_tokens', 'oauth_applications', 'oauth_access_grants']).each do |table|
        table.classify.constantize.delete_all
    end
  end
end