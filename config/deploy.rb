# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'eucportal'
set :repo_url, 'git@github.com:eucglobaldemo/eucportal.git'
set :deploy_to, '/home/rails/app'
set :scm, :git
set :branch, 'rework'
set :keep_releases, 5
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

namespace :deploy do
  desc 'Runs rake db:seed'
  task :seed => [:set_rails_env] do
    on primary fetch(:migration_role) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, "db:seed"
        end
      end
    end
  end
end