Sipity::Models::WorkTypeTodoListConfig.create!(
  work_type: 'etd',
  work_processing_state: 'new',
  enrichment_type: 'describe',
  enrichment_group: 'required'
)

work_types = {}
Sipity::Models::WorkType.valid_names.each do |work_type_name|
  work_types[work_type_name] = Sipity::Models::WorkType.find_or_create_by!(name: work_type_name)
end

roles = {}
[
  'creating_user',
  'etd_reviewer',
  'advisor'
].each do |role_name|
  roles[role_name] = Sipity::Models::Role.find_or_create_by!(name: role_name)
end

work_types.fetch('etd').find_or_initialize_default_processing_strategy do |etd_strategy|
  etd_strategy_roles = {}

  [
    'creating_user',
    'etd_reviewer',
    'advisor'
  ].each do |role_name|
    etd_strategy_roles[role_name] = etd_strategy.strategy_roles.find_or_initialize_by(role: roles.fetch(role_name))
  end
end.save!

count = Sipity::Models::Processing::StrategyRole.count
