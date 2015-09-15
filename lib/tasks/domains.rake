require 'open-uri'

namespace :domains do
  task :import => :environment do
    if ENV['from'].blank?
      puts "Source not given. Please run as `rake domains:import from=/path/or.uri`"
      exit
    end

    if ENV['profile'].blank?
      puts "Profile not given. Please run as `rake domains:import profile='Profile A'"
      exit
    end

    source     = ENV['from']
    user_role  = ENV['role'] || 'basic'
    profile    = Profile.where(name: ENV['profile']).first
    user_roles = User::ROLES.keys.map(&:to_s)

    unless user_roles.include?(user_role)
      puts "The requested role '#{user_role}' is not one of: #{user_roles.join(', ')}"
    end

    if profile.blank?
      puts "Profile '#{ENV['profile']}' is not found"
    end

    open source do |f|
      f.each_line do |line|
        domain = Domain.new(name: line.strip, profile: profile, user_role: user_role)

        if domain.valid?
          domain.save!
        else
          puts "'#{domain.name}' is invalid and can't be saved: #{domain.errors.full_messages}"
        end
      end
    end
  end
end