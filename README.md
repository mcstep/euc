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

### Development Environment

Development environment is managed by [Docker Compose](https://larry-price.com/blog/2015/02/26/a-quick-guide-to-using-docker-compose-previously-fig). To use provisioned development container you need to (install Docker)[https://docs.docker.com/installation/#installation]).

The required systems are installed by following command (run from project root):

    docker-compose build
    docker-compose up

In this mode containers do not go to background. Instead you get to colored Heroku-like output coming from every one of them. If you want to have them background instead use the following commands:

    docker-compose stop
    docker-compose start

If you are on Linux you might consider adding following lines to your `~/.ssh/config`

    Host 127.0.0.1
      StrictHostKeyChecking no
      UserKnownHostsFile /dev/null

After that the main application container can be easily accessed via ssh (run fom project root):

    ./bin/ssh

The installed server is provisioned by the same script that is used to provision production and staging servers so the environment is nearly identical. The project working dir is mirrored to `/app`.

### Services

The environment is configured to forward port 3000 from Docker host machine to application container. Rails however start development server that listens only to local connections. To make it accessible to you this is how it should be started:

    rails s -b 0.0.0.0

After that it can be accessed at `http://localhost:3000` (run `boot2docker ip` to get host ip and use it instead of localhost if you are not running Linux.

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

### Infrastructure provisioning

The provisioning is done with ansible. The root playbook is located at `provision/ansible.yml`. Inventory files are located at `provision/ansible.hosts.staging` and `provision/ansible.hosts.production`.