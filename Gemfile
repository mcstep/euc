source 'https://rubygems.org'

gem 'rails', '4.1.0'

group :production, :staging do
  gem "pg"
end

group :development, :test do
  gem "sqlite3"
end

gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0',          group: :doc
gem 'spring',        group: :development
gem 'figaro', :github=>"laserlemon/figaro"
gem 'passenger'
gem 'therubyracer', :platform=>:ruby
group :development do
  gem 'better_errors'
  gem 'binding_of_caller', :platforms=>[:mri_21]
  gem 'quiet_assets'
  gem 'rails_layout'
end
group :development, :test do
  gem 'pry-rails'
  gem 'pry-rescue'
end
gem 'rest-client'
gem 'rails_12factor', group: :production

gem 'sidekiq'

gem 'sinatra', require: false
gem 'slim'

gem 'unicorn'

gem 'pundit'
gem 'bootstrap-datepicker-rails'

gem 'newrelic_rpm'

gem "paranoia", "~> 2.0"

gem 'cloudinary'

gem 'kaminari'

gem 'google-api-client'

gem 'rqrcode_png'

gem 'wannabe_bool'
gem 'bazaar'
