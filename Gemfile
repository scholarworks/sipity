source 'https://rubygems.org'
ruby '2.1.5'
gem 'rails', '4.2.0'
gem 'responders', '~> 2.0.0'
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'bootstrap-sass'
gem 'devise'
gem 'figaro', '>= 1.0.0.rc1'
gem 'high_voltage'
gem 'pundit'
gem 'simple_form'
gem 'upmin-admin'
gem 'draper', '~> 1.4'
gem 'devise_cas_authenticatable'
gem 'hesburgh-lib', github: 'ndlib/hesburgh-lib'
gem 'ezid-client', github: 'duke-libraries/ezid-client'
gem 'micromachine', github: 'jeremyf/micromachine' # Ensuring code continues to exist
gem 'dragonfly', '~> 1.0.7'

group :doc do
  gem 'yard', require: false
  gem 'inch', require: false
  gem 'railroady', require: false
end

group :development do
  gem 'spring'
  gem 'better_errors'
  gem 'binding_of_caller', :platforms=>[:mri_21]
  gem 'capistrano', '~> 3.0.1'
  gem 'capistrano-bundler'
  gem 'capistrano-rails', '~> 1.1.0'
  gem 'capistrano-rails-console'
  gem 'capistrano-rvm', '~> 0.1.1'
  gem 'guard-bundler'
  gem 'guard-rails'
  gem 'guard-rspec'
  gem 'guard-spring'
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
  gem 'pry-rescue'
  gem 'pry-byebug'
  gem 'letter_opener'
end

group :development, :test do
  gem 'sqlite3'
  gem 'rubocop', require: false
  gem 'faker'
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'coveralls', require: false
end

group :test do
  gem 'rspec-given'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'site_prism'
  gem 'simplecov'
  gem 'rspec-html-matchers', '~>0.6'
  gem 'selenium-webdriver'
end

group :production, :pre_production, :staging do
  gem 'unicorn'
  gem 'mysql2'
end
