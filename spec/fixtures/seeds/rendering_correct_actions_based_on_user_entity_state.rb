User.create!([
  {email: "test@example.com", remember_created_at: nil, sign_in_count: 2, current_sign_in_at: "2015-02-24 18:32:52", last_sign_in_at: "2015-02-24 18:32:52", current_sign_in_ip: "127.0.0.1", last_sign_in_ip: "127.0.0.1", name: "Test User", role: nil, username: "test@example.com"}
])
Sipity::Models::Processing::Actor.create!([
  {proxy_for_id: 1, proxy_for_type: "User", name_of_proxy: nil}
])
Sipity::Models::Processing::Entity.create!([
  {proxy_for_id: 1, proxy_for_type: "Sipity::Models::Work", strategy_id: 1, strategy_state_id: "2"}
])
Sipity::Models::Processing::EntityActionRegister.create!([
  {strategy_action_id: 2, entity_id: 1, subject_id: 1, subject_type: "Sipity::Models::Processing::Entity", requested_by_actor_id: 1, on_behalf_of_actor_id: 1},
  {strategy_action_id: 4, entity_id: 1, subject_id: 1, subject_type: "Sipity::Models::Processing::Entity", requested_by_actor_id: 1, on_behalf_of_actor_id: 1},
  {strategy_action_id: 5, entity_id: 1, subject_id: 1, subject_type: "Sipity::Models::Processing::Entity", requested_by_actor_id: 1, on_behalf_of_actor_id: 1},
  {strategy_action_id: 6, entity_id: 1, subject_id: 1, subject_type: "Sipity::Models::Processing::Entity", requested_by_actor_id: 1, on_behalf_of_actor_id: 2}
])
Sipity::Models::Processing::EntitySpecificResponsibility.create!([
  {strategy_role_id: 1, entity_id: 1, actor_id: 1}
])
Sipity::Models::Processing::Strategy.create!([
  {name: "doctoral_dissertation processing", description: nil}
])
Sipity::Models::Processing::StrategyUsage.create!([
  {strategy_id: 1, usage_id: 1, usage_type: 'Sipity::Models::WorkType'}
])
Sipity::Models::Processing::StrategyAction.create!([
  {strategy_id: 1, name: "show", action_type: "resourceful_action"},
  {strategy_id: 1, name: "describe", action_type: "enrichment_action"},
  {strategy_id: 1, name: "assign_a_doi", action_type: "enrichment_action"},
  {strategy_id: 1, resulting_strategy_state_id: 2, name: "submit_for_review", action_type: "state_advancing_action"},
  {strategy_id: 1, allow_repeat_within_current_state: false, name: "already_taken_on_behalf" },
  {strategy_id: 1, allow_repeat_within_current_state: false, name: "already_taken_but_by_someone_else" },
  {strategy_id: 1, allow_repeat_within_current_state: false, name: "analog_to_submit_for_review" }
])
Sipity::Models::Processing::StrategyActionAnalogue.create!([
  {strategy_action_id: 7, analogous_to_strategy_action_id: 4}
])
Sipity::Models::Processing::StrategyActionPrerequisite.create!([
  {guarded_strategy_action_id: 4, prerequisite_strategy_action_id: 2}
])
Sipity::Models::Processing::StrategyRole.create!([
  {strategy_id: 1, role_id: 1},
  {strategy_id: 1, role_id: 2},
  {strategy_id: 1, role_id: 3}
])
Sipity::Models::Processing::StrategyState.create!([
  {strategy_id: 1, name: "new"},
  {strategy_id: 1, name: "under_advisor_review"}
])
Sipity::Models::Processing::StrategyStateAction.create!([
  {originating_strategy_state_id: 1, strategy_action_id: 1},
  {originating_strategy_state_id: 2, strategy_action_id: 1},
  {originating_strategy_state_id: 1, strategy_action_id: 2},
  {originating_strategy_state_id: 1, strategy_action_id: 3},
  {originating_strategy_state_id: 2, strategy_action_id: 3},
  {originating_strategy_state_id: 1, strategy_action_id: 4},
  {originating_strategy_state_id: 1, strategy_action_id: 5},
  {originating_strategy_state_id: 2, strategy_action_id: 5},
  {originating_strategy_state_id: 1, strategy_action_id: 6},
  {originating_strategy_state_id: 2, strategy_action_id: 6},
  {originating_strategy_state_id: 1, strategy_action_id: 7},
  {originating_strategy_state_id: 2, strategy_action_id: 7}
])
Sipity::Models::Processing::StrategyStateActionPermission.create!([
  {strategy_role_id: 1, strategy_state_action_id: 6},
  {strategy_role_id: 1, strategy_state_action_id: 1},
  {strategy_role_id: 1, strategy_state_action_id: 3},
  {strategy_role_id: 1, strategy_state_action_id: 4},
  {strategy_role_id: 1, strategy_state_action_id: 2},
  {strategy_role_id: 2, strategy_state_action_id: 1},
  {strategy_role_id: 2, strategy_state_action_id: 3},
  {strategy_role_id: 2, strategy_state_action_id: 4},
  {strategy_role_id: 2, strategy_state_action_id: 2},
  {strategy_role_id: 2, strategy_state_action_id: 5},
  {strategy_role_id: 3, strategy_state_action_id: 1},
  {strategy_role_id: 3, strategy_state_action_id: 2},
  {strategy_role_id: 2, strategy_state_action_id: 6},
  {strategy_role_id: 2, strategy_state_action_id: 7},
  {strategy_role_id: 2, strategy_state_action_id: 8},
  {strategy_role_id: 2, strategy_state_action_id: 9},
  {strategy_role_id: 2, strategy_state_action_id: 10},
  {strategy_role_id: 2, strategy_state_action_id: 11},
  {strategy_role_id: 2, strategy_state_action_id: 12},
  {strategy_role_id: 1, strategy_state_action_id: 7},
  {strategy_role_id: 1, strategy_state_action_id: 8},
  {strategy_role_id: 1, strategy_state_action_id: 9},
  {strategy_role_id: 1, strategy_state_action_id: 10},
  {strategy_role_id: 1, strategy_state_action_id: 11},
  {strategy_role_id: 1, strategy_state_action_id: 12}
])
Sipity::Models::Role.create!([
  {name: "creating_user", description: nil},
  {name: "etd_reviewing", description: nil},
  {name: "advising", description: nil}
])
Sipity::Models::WorkType.create!([
  {name: "doctoral_dissertation", description: nil}
])
