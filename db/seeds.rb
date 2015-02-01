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

  $stdout.puts 'Configuring Work Type Todo List...'

  [
    ['etd', 'new', 'describe', 'required'],
    ['etd', 'new', 'attach', 'required']
  ].each do |work_type, processing_state, enrichment_type, enrichment_group|
    Sipity::Models::WorkTypeTodoListConfig.create!(
      work_type: work_type,
      work_processing_state: processing_state,
      enrichment_type: enrichment_type,
      enrichment_group: enrichment_group
    )
  end

  $stdout.puts 'Creating ETD Reviewer Role...'
  roles = {}

  ['creating_user', 'etd_reviewer', 'advisor'].each do |role_name|
    roles[role_name] = Sipity::Models::Role.create!(name: role_name)
  end

  $stdout.puts 'Creating ETD State Diagram...'
  Sipity::Models::Processing::Strategy.create!(name: 'etd') do |etd_strategy|
    etd_strategy_roles = {}

    ['creating_user', 'etd_reviewer', 'advisor'].each do |role_name|
      etd_strategy_roles[role_name] = etd_strategy.strategy_roles.build(role: roles.fetch(role_name))
    end

    etd_states = {}
    [
      'new', 'under_advisor_review', 'advisor_changes_requested', 'under_grad_school_review',
      'ready_for_ingest', 'ingesting', 'done'
    ].each do |name|
      etd_states[name] = etd_strategy.strategy_states.build(name: name)
    end

    etd_actions = {}
    [
      'submit_for_advisor_signoff', 'advisor_signs_off', 'advisor_requests_changes',
      'student_submits_advisor_requested_changes', 'request_revisions', 'approve_for_ingest',
      'ingest', 'ingest_completed'
    ].each do |name|
      etd_actions[name] = etd_strategy.strategy_actions.build(name: name)
    end

    [
      ['new', 'submit_for_advisor_signoff', 'under_advisor_review', ['creating_user']]
    ].each do |originating, action_name, resulting, role_names|
      action = etd_actions.fetch(action_name)
      originating_state = etd_states.fetch(originating)
      resulting_state = etd_states.fetch(resulting)

      event = action.strategy_events.build(
        originating_strategy_state: originating_state, resulting_strategy_state: resulting_state
      )

      Array.wrap(role_names).each do |role_name|
        etd_strategy_roles.fetch(role_name).strategy_event_permissions.build(strategy_event: event)
      end
    end
  end
end
