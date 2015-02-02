# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# Environment variables (ENV['...']) can be set in the file config/application.yml.
# See http://railsapps.github.io/rails-environment-variables.html

$stdout.puts 'Configuring Work Type Todo List...'
[
  ['etd', 'new', 'describe', 'required'],
  ['etd', 'new', 'attach', 'required'],
  ['etd', 'new', 'advisors', 'required']
].each do |work_type, processing_state, enrichment_type, enrichment_group|
  Sipity::Models::WorkTypeTodoListConfig.create!(
    work_type: work_type,
    work_processing_state: processing_state,
    enrichment_type: enrichment_type,
    enrichment_group: enrichment_group
  )
end
