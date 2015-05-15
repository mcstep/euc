Portal
======

This application was generated with the [rails_apps_composer](https://github.com/RailsApps/rails_apps_composer) gem provided by the [RailsApps Project](http://railsapps.github.io/).

### Requirements

- Ruby
- Rails
- libpg

Learn more about [Installing Rails](http://railsapps.github.io/installing-rails.html).

### Database

This application requires SQLite (with ActiveRecord) in development and PostgreSQL in production mode.

### Getting Started

This project defines 4 groups: **development**, **test**, **staging**, and **production**.
You can can disable those groups during the installation in the first step.
E.g. in a development environment this might be installed using `bundle install --without test staging production`, or updated using `bundle update --group development`.

- `bundle install` (If you encounter any errors, please try to remove **Gemfile.lock**)
- `bundle exec rake db:migrate`
- `bundle exec rake add_first_dev_user`
- `bundle exec rake synchronize_users_with_invitations`
- `rails server`
- The server should be reachable under http://localhost:3000/
- Login using `first.user` and the password given to you by the Administrator (Ashutosh Joshi)
