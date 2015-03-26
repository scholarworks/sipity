source 'https://rubygems.org'
gem 'rails', '~> 4.2'
gem 'responders', '~> 2.0'
gem 'sass-rails'
gem 'uglifier'
gem 'coffee-rails', '~> 4.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'bootstrap-sass'
gem 'devise'
gem 'figaro'
gem 'high_voltage'
gem 'simple_form'
gem 'rdiscount'
gem 'sanitize', '~> 2.1.0'
gem 'draper', '~> 1.4'
gem 'devise_cas_authenticatable'
gem 'hesburgh-lib', github: 'ndlib/hesburgh-lib'
gem 'ezid-client', github: 'duke-libraries/ezid-client'
gem 'noids_client', git: 'git://github.com/ndlib/noids_client'
gem 'dragonfly', '~> 1.0.7'
gem 'execjs'

group :doc do
  gem 'yard', require: false
  gem 'inch', require: false
  gem 'railroady', require: false
end

group :development do
  gem 'spring'
  gem 'better_errors'
  gem 'binding_of_caller', :platforms=>[:mri_21]
  gem 'capistrano', '~> 3.1'
  gem 'capistrano-rails'
  gem 'capistrano-bundler'
  gem 'capistrano-rails-console'
  gem 'capistrano-rvm', '~> 0.1.1'
  gem 'guard-bundler'
  gem 'guard-rails'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'i18n-debug'
  gem 'quiet_assets'
  gem 'rails_layout'
  gem 'rb-fchange', :require=>false
  gem 'rb-fsevent', :require=>false
  gem 'rb-inotify', :require=>false
  gem 'spring-commands-rspec'
  gem 'terminal-notifier'
  gem 'terminal-notifier-guard', '~> 1.6.4'
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'letter_opener'
  gem 'seed_dump'
  # Paired with Chrome the RailsPanel plugin, you can see request information
  # https://github.com/dejan/rails_panel
  gem 'meta_request'
end

group :development, :test do
  gem 'sqlite3'
  gem 'rubocop', require: false
  gem 'faker'
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'pry-rescue', require: false
  gem 'pry-stack_explorer', require: false
end

group :test do
  gem 'rspec-given'
  gem 'capybara'
  gem "capybara-accessible", require: false
  gem "poltergeist"
  gem 'database_cleaner'
  gem 'launchy'
  gem 'site_prism'
  gem "codeclimate-test-reporter", require: nil
  gem 'simplecov', require: false
  gem 'rspec-html-matchers', '~>0.6'
  gem 'selenium-webdriver'
end

group :production, :pre_production, :staging do
  gem 'mysql2'
  gem 'rack-cache', require: 'rack/cache'
  gem 'dragonfly-s3_data_store'
end
