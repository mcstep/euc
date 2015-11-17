source 'https://rubygems.org'

gem 'rails', '4.2.2'

#
# Deployment
#
gem 'unicorn'
gem 'figaro'

#
# General Flow
#
gem 'inherited_resources'
gem 'pundit'
gem 'sidekiq'
gem 'sinatra', require: nil
gem 'seedbank'
gem 'doorkeeper'
gem 'versionist'

#
# Data sources
#
gem 'pg'
gem 'sqlite3' # dev mode for poors
gem 'redis-objects'
gem 'redis-semaphore'
gem 'geoip'
gem 'iso_country_codes'

#
# AR Enhancers
#
gem 'kaminari'
gem 'micromachine'
gem 'paranoia', '~> 2.0'
gem 'simple_enum'
gem 'carrierwave'
gem 'carrierwave-data-uri'
gem 'cloudinary'
gem 'validates_hostname', '~> 1.0.0'

#
# Renderers
#
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'haml'
gem 'jbuilder', '~> 2.0'
gem 'bootstrap_form'
gem 'nested_form'
gem 'bootstrap-kaminari-views'
gem 'active_model_serializers', github: 'rails-api/active_model_serializers', branch: '0-10-stable'

#
# Assets
#
gem 'bootstrap-sass', '~> 3.3.5'
gem 'bootstrap-datepicker-rails'
gem 'bootstrap-multiselect-rails'
gem 'spinjs-rails'
gem 'switchery-rails'
gem 'jquery-rails'
gem 'jquery-cookie-rails'
gem 'momentjs-rails', '>= 2.9.0'
gem 'bootstrap3-datetimepicker-rails', '~> 4.15.35'
gem 'codemirror-rails'

#
# Services
#
gem 'rest-client', '1.6.7'
gem 'google-api-client', '0.8.6'
gem 'azure-directory', github: 'kioru/azure-directory'
gem 'faraday-conductivity'
gem 'nexmo'
gem 'restforce'
gem 'mechanize'
gem 'mandrill-api', require: 'mandrill'

#
# Tools
#
gem 'newrelic_rpm'
gem 'le'
gem 'bugsnag', group: :production
gem 'appsignal', '~> 0.12.rc', group: :production

#
# Misc
#
gem 'rqrcode_png'
gem 'readable-token'
gem 'wannabe_bool'

group :development, :test do
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'poltergeist'
  gem 'ffaker'
  gem 'spring-commands-rspec'
  gem 'rspec-rails', '~> 3.0'
  gem 'rspec-activemodel-mocks'
  gem 'rspec-collection_matchers'
  gem 'quiet_assets'
  gem 'byebug'
  gem 'web-console', '~> 2.0'
  gem 'spring'
  gem 'pry-rails'
  gem 'capistrano',  '~> 3.1'
  gem 'capistrano-rails'
  gem 'capistrano-rvm'
  gem 'capistrano-passenger'
  gem 'letter_opener'
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-bundler'
  gem 'launchy'
  gem 'annotate', '~> 2.6.6'
  gem 'simplecov', :require => false
  gem 'simplecov-summary'
end

group :test do
  gem 'vcr'
  gem 'webmock'
  gem 'fantaskspec'
  gem 'rack_session_access'
  gem 'show_me_the_cookies'
  gem 'test_after_commit'
  gem 'json_spec'
end
