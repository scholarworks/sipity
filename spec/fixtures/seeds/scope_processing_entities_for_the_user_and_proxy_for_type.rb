work_types = {}
Sipity::Models::WorkType.valid_names.each do |work_type_name|
  work_types[work_type_name] = Sipity::Models::WorkType.find_or_create_by!(name: work_type_name)
end

roles = {}
[
  'creating_user',
  "etd_reviewing",
  'advising'
].each do |role_name|
  roles[role_name] = Sipity::Models::Role.find_or_create_by!(name: role_name)
end

Sipity::DataGenerators::FindOrCreateWorkType.call(name: 'doctoral_dissertation') do |work_type, etd_strategy, initial_state|
  etd_strategy_roles = {}

  [
    'creating_user',
    "etd_reviewing",
    'advising'
  ].each do |role_name|
    etd_strategy_roles[role_name] = etd_strategy.strategy_roles.find_or_create_by!(role: roles.fetch(role_name))
  end
  etd_states = {}
  [
    'new',
    'under_advisor_review',
  ].each do |state_name|
    etd_states[state_name] = etd_strategy.strategy_states.find_or_create_by!(name: state_name)
  end

  etd_actions = {}
  [
    ['show', nil],
    ['describe', nil],
    ['submit_for_review', 'under_advisor_review'],
  ].each do |action_name, strategy_state_name, action_type|
    resulting_state = strategy_state_name ? etd_states.fetch(strategy_state_name) : nil
    etd_actions[action_name] = etd_strategy.strategy_actions.find_or_create_by(
      name: action_name, resulting_strategy_state: resulting_state
    )
  end

  [
    ['submit_for_review', ['describe']]
  ].each do |guarded_action_name, prereq_action_names|
    guarded_action = etd_actions.fetch(guarded_action_name)
    Array.wrap(prereq_action_names).each do |prereq_action_name|
      prereq_action = etd_actions.fetch(prereq_action_name)
      guarded_action.requiring_strategy_action_prerequisites.create!(prerequisite_strategy_action: prereq_action)
    end
  end

  [
    ['new', 'submit_for_review', ['creating_user']],
    ['new', 'show', ['creating_user', 'advising', "etd_reviewing"]],
    ['new', 'describe', ['creating_user', "etd_reviewing"]],
    ['under_advisor_review', 'show', ['creating_user', 'advising', "etd_reviewing"]],
  ].each do |originating_state_name, action_name, role_names|
    action = etd_actions.fetch(action_name)
    originating_state = etd_states.fetch(originating_state_name)
    event = action.strategy_state_actions.find_or_create_by!(originating_strategy_state: originating_state)

    Array.wrap(role_names).each do |role_name|
      etd_strategy_roles.fetch(role_name).strategy_state_action_permissions.find_or_create_by!(strategy_state_action: event)
    end
  end
end
