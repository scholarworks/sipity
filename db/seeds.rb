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
    ['etd', 'new', 'attach', 'required'],
    ['etd', 'new', 'collaborators', 'required']
  ].each do |work_type, processing_state, enrichment_type, enrichment_group|
    Sipity::Models::WorkTypeTodoListConfig.find_or_create_by!(
      work_type: work_type,
      work_processing_state: processing_state,
      enrichment_type: enrichment_type,
      enrichment_group: enrichment_group
    )
  end

  $stdout.puts 'Creating ETD Reviewer Role...'
  roles = {}

  [
    'creating_user',
    'etd_reviewer',
    'advisor'
  ].each do |role_name|
    roles[role_name] = Sipity::Models::Role.find_or_create_by!(name: role_name)
  end

  $stdout.puts 'Creating ETD State Diagram...'
  Sipity::Models::Processing::Strategy.find_or_create_by!(name: 'etd') do |etd_strategy|
    etd_strategy_roles = {}

    [
      'creating_user',
      'etd_reviewer',
      'advisor'
    ].each do |role_name|
      etd_strategy_roles[role_name] = etd_strategy.strategy_roles.find_or_initialize_by(role: roles.fetch(role_name))
    end

    etd_states = {}
    [
      'new',
      'under_advisor_review',
      'advisor_changes_requested',
      'under_grad_school_review',
      'ready_for_ingest',
      'ingesting',
      'done'
    ].each do |state_name|
      etd_states[state_name] = etd_strategy.strategy_states.find_or_initialize_by(name: state_name)
    end

    etd_actions = {}
    [
      ['show', nil],
      ['edit', nil],
      ['destroy', nil],
      ['submit_for_advisor_signoff', 'under_advisor_review'],
      ['advisor_signs_off', 'under_grad_school_review'],
      ['advisor_requests_changes', 'advisor_changes_requested'],
      ['student_submits_advisor_requested_changes', 'under_advisor_review'],
      ['request_revisions', 'under_advisor_review'],
      ['approve_for_ingest', 'ready_for_ingest'],
      ['ingest', 'ingesting'],
      ['ingest_completed', 'done']
    ].each do |action_name, strategy_state_name|
      resulting_state = strategy_state_name ? etd_states.fetch(strategy_state_name) : nil
      etd_actions[action_name] = etd_strategy.strategy_events.find_or_initialize_by(name: action_name, resulting_strategy_state: resulting_state)
    end

    [
      ['new', 'submit_for_advisor_signoff', ['creating_user']],
      ['new', 'show', ['creating_user', 'advisor', 'etd_reviewer']],
      ['new', 'edit', ['creating_user', 'etd_reviewer']],
      ['new', 'destroy', ['creating_user', 'etd_reviewer']],
    ].each do |originating_state_name, action_name, role_names|
      action = etd_actions.fetch(action_name)
      originating_state = etd_states.fetch(originating_state_name)
      event = action.strategy_actions.find_or_initialize_by(originating_strategy_state: originating_state)

      Array.wrap(role_names).each do |role_name|
        etd_strategy_roles.fetch(role_name).strategy_action_permissions.find_or_initialize_by(strategy_action: event)
      end
    end
  end
end
