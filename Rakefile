# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new do |t|
    t.options << '--config=./.hound.yml'
  end
rescue LoadError
  puts "Unable to load rubocop. Who will enforce your styles now?"
end

namespace :spec do
  desc "Run all specs"
  RSpec::Core::RakeTask.new(:all) do
    ENV['COVERAGE'] = 'true'
  end

  desc 'Run the Travis CI specs'
  task travis: [:rubocop] do
    ENV['SPEC_OPTS'] = "--profile 5"
    Rake::Task['spec:all'].invoke
  end
end

Rake::Task["default"].clear
task default: ['rubocop', 'spec:all']
