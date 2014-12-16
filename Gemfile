source 'https://rubygems.org'
ruby '2.1.5'
gem 'rails', '4.1.7'
gem 'sqlite3'
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
gem 'hesburgh-lib', github: 'ndlib/hesburgh-lib'
gem 'ezid-client', github: 'duke-libraries/ezid-client'
gem 'micromachine', github: 'jeremyf/micromachine' # Ensuring code continues to exist
group :doc do
  gem 'yard'
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
  gem 'quiet_assets'
  gem 'rails_layout'
  gem 'rb-fchange', :require=>false
  gem 'rb-fsevent', :require=>false
  gem 'rb-inotify', :require=>false
  gem 'spring-commands-rspec'
  if RUBY_PLATFORM =~ /darwin12/
    gem 'terminal-notifier-guard', '~> 1.5.3'
  else
    gem 'terminal-notifier-guard'
  end
end
group :development, :test do
  gem 'rubocop', require: false
  gem 'faker'
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'coveralls', require: false
end
group :development do
  gem 'pry-rails'
  gem 'pry-rescue'
  gem 'pry-byebug'
end
group :production do
  gem 'unicorn'
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
