# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# Environment variables (ENV['...']) can be set in the file config/application.yml.
# See http://railsapps.github.io/rails-environment-variables.html
ActiveRecord::Base.transaction do
  # Order is important
  [
    'groups_and_roles',
    'controlled_vocabularies',
    'etd_work_area',
    'ulra_work_area'
  ].each do |seed_filename|
    load File.expand_path("../seeds/#{seed_filename}_seeds.rb", __FILE__)
  end
end
