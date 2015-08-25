namespace :users do
  task :extend => :environment do
    period = ENV['EXTEND_ROOTS_DAYS'].to_i rescue 0
    period = 15 unless period > 0

    User.where(role: [User::ROLES[:root], User::ROLES[:admin]]).expiring_soon(period.days).each do |u|
      DirectoryProlongation.create! user_integration: u.authentication_integration,
        reason: 'Auto Extension',
        period: 1.year
    end
  end
end