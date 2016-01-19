# TODO: The purpose of this data is to establsih a set of data in which not
# all of the pre-requisites have been achieved.
#
# This data was generated via rake db:seed:dump
# It is used for a specific test.
User.create!([
  {email: nil, remember_created_at: nil, sign_in_count: 1, current_sign_in_at: "2015-02-23 15:05:46", last_sign_in_at: "2015-02-23 15:05:46", current_sign_in_ip: "::1", last_sign_in_ip: "::1", name: nil, role: nil, username: "jfriesen"}
])
Sipity::Models::Processing::Actor.create!([
  {proxy_for_id: 1, proxy_for_type: "User", name_of_proxy: nil}
])
Sipity::Models::Processing::Entity.create!([
  {proxy_for_id: 1, proxy_for_type: "Sipity::Models::Work", strategy_id: 1, strategy_state_id: "1"}
])
Sipity::Models::Processing::EntityActionRegister.create!([
  {strategy_action_id: 4, entity_id: 1, requested_by_actor_id: 1, on_behalf_of_actor_id: 1, subject_id: 1, subject_type: 'Sipity::Models::Processing::Entity'}
])
Sipity::Models::Processing::EntitySpecificResponsibility.create!([
  {strategy_role_id: 1, entity_id: 1, actor_id: 1}
])
Sipity::Models::Processing::Strategy.create!([
  {name: "etd processing", description: nil}
])
Sipity::Models::Processing::StrategyUsage.create!([
  {strategy_id: 1, usage_id: 1, usage_type: 'Sipity::Models::WorkType'}
])
Sipity::Models::Processing::StrategyAction.create!([
  {strategy_id: 1, resulting_strategy_state_id: nil, name: "show", action_type: "resourceful_action"},
  {strategy_id: 1, resulting_strategy_state_id: nil, name: "edit", action_type: "resourceful_action"},
  {strategy_id: 1, resulting_strategy_state_id: nil, name: "destroy", action_type: "resourceful_action"},
  {strategy_id: 1, resulting_strategy_state_id: nil, name: "describe", action_type: "enrichment_action"},
  {strategy_id: 1, resulting_strategy_state_id: nil, name: "attach", action_type: "enrichment_action"},
  {strategy_id: 1, resulting_strategy_state_id: nil, name: "collaborators", action_type: "enrichment_action"},
  {strategy_id: 1, resulting_strategy_state_id: nil, name: "assign_a_doi", action_type: "enrichment_action"},
  {strategy_id: 1, resulting_strategy_state_id: nil, name: "assign_a_citation", action_type: "enrichment_action"},
  {strategy_id: 1, resulting_strategy_state_id: 2, name: "submit_for_review", action_type: "state_advancing_action"},
  {strategy_id: 1, resulting_strategy_state_id: 4, name: "advisor_signs_off", action_type: "state_advancing_action"},
  {strategy_id: 1, resulting_strategy_state_id: 3, name: "advisor_requests_changes", action_type: "state_advancing_action"},
  {strategy_id: 1, resulting_strategy_state_id: 2, name: "request_revision", action_type: "state_advancing_action"},
  {strategy_id: 1, resulting_strategy_state_id: 5, name: "grad_school_signoff", action_type: "state_advancing_action"},
  {strategy_id: 1, resulting_strategy_state_id: 6, name: "ingest", action_type: "state_advancing_action"},
  {strategy_id: 1, resulting_strategy_state_id: 7, name: "ingest_completed", action_type: "state_advancing_action"}
])
Sipity::Models::Processing::StrategyActionPrerequisite.create!([
  {guarded_strategy_action_id: 9, prerequisite_strategy_action_id: 4},
  {guarded_strategy_action_id: 9, prerequisite_strategy_action_id: 5},
  {guarded_strategy_action_id: 9, prerequisite_strategy_action_id: 6}
])
Sipity::Models::Processing::StrategyRole.create!([
  {strategy_id: 1, role_id: 1},
  {strategy_id: 1, role_id: 2},
  {strategy_id: 1, role_id: 3}
])
Sipity::Models::Processing::StrategyState.create!([
  {strategy_id: 1, name: "new"},
  {strategy_id: 1, name: "under_advisor_review"},
  {strategy_id: 1, name: "advisor_changes_requested"},
  {strategy_id: 1, name: "under_grad_school_review"},
  {strategy_id: 1, name: "ready_for_ingest"},
  {strategy_id: 1, name: "ingesting"},
  {strategy_id: 1, name: "done"}
])
Sipity::Models::Processing::StrategyStateAction.create!([
  {originating_strategy_state_id: 1, strategy_action_id: 1},
  {originating_strategy_state_id: 2, strategy_action_id: 1},
  {originating_strategy_state_id: 3, strategy_action_id: 1},
  {originating_strategy_state_id: 4, strategy_action_id: 1},
  {originating_strategy_state_id: 5, strategy_action_id: 1},
  {originating_strategy_state_id: 6, strategy_action_id: 1},
  {originating_strategy_state_id: 7, strategy_action_id: 1},
  {originating_strategy_state_id: 1, strategy_action_id: 2},
  {originating_strategy_state_id: 3, strategy_action_id: 2},
  {originating_strategy_state_id: 4, strategy_action_id: 2},
  {originating_strategy_state_id: 1, strategy_action_id: 3},
  {originating_strategy_state_id: 2, strategy_action_id: 3},
  {originating_strategy_state_id: 3, strategy_action_id: 3},
  {originating_strategy_state_id: 4, strategy_action_id: 3},
  {originating_strategy_state_id: 1, strategy_action_id: 4},
  {originating_strategy_state_id: 1, strategy_action_id: 5},
  {originating_strategy_state_id: 1, strategy_action_id: 6},
  {originating_strategy_state_id: 1, strategy_action_id: 7},
  {originating_strategy_state_id: 2, strategy_action_id: 7},
  {originating_strategy_state_id: 3, strategy_action_id: 7},
  {originating_strategy_state_id: 4, strategy_action_id: 7},
  {originating_strategy_state_id: 1, strategy_action_id: 8},
  {originating_strategy_state_id: 2, strategy_action_id: 8},
  {originating_strategy_state_id: 3, strategy_action_id: 8},
  {originating_strategy_state_id: 4, strategy_action_id: 8},
  {originating_strategy_state_id: 1, strategy_action_id: 9},
  {originating_strategy_state_id: 2, strategy_action_id: 10},
  {originating_strategy_state_id: 2, strategy_action_id: 11},
  {originating_strategy_state_id: 4, strategy_action_id: 12}
])
Sipity::Models::Processing::StrategyStateActionPermission.create!([
  {strategy_role_id: 1, strategy_state_action_id: 26},
  {strategy_role_id: 1, strategy_state_action_id: 1},
  {strategy_role_id: 1, strategy_state_action_id: 8},
  {strategy_role_id: 1, strategy_state_action_id: 15},
  {strategy_role_id: 1, strategy_state_action_id: 16},
  {strategy_role_id: 1, strategy_state_action_id: 17},
  {strategy_role_id: 1, strategy_state_action_id: 11},
  {strategy_role_id: 1, strategy_state_action_id: 18},
  {strategy_role_id: 1, strategy_state_action_id: 22},
  {strategy_role_id: 1, strategy_state_action_id: 2},
  {strategy_role_id: 1, strategy_state_action_id: 20},
  {strategy_role_id: 1, strategy_state_action_id: 24},
  {strategy_role_id: 1, strategy_state_action_id: 3},
  {strategy_role_id: 1, strategy_state_action_id: 9},
  {strategy_role_id: 1, strategy_state_action_id: 13},
  {strategy_role_id: 1, strategy_state_action_id: 4},
  {strategy_role_id: 1, strategy_state_action_id: 5},
  {strategy_role_id: 1, strategy_state_action_id: 6},
  {strategy_role_id: 1, strategy_state_action_id: 7},
  {strategy_role_id: 2, strategy_state_action_id: 1},
  {strategy_role_id: 2, strategy_state_action_id: 8},
  {strategy_role_id: 2, strategy_state_action_id: 15},
  {strategy_role_id: 2, strategy_state_action_id: 16},
  {strategy_role_id: 2, strategy_state_action_id: 17},
  {strategy_role_id: 2, strategy_state_action_id: 11},
  {strategy_role_id: 2, strategy_state_action_id: 18},
  {strategy_role_id: 2, strategy_state_action_id: 22},
  {strategy_role_id: 2, strategy_state_action_id: 2},
  {strategy_role_id: 2, strategy_state_action_id: 19},
  {strategy_role_id: 2, strategy_state_action_id: 23},
  {strategy_role_id: 2, strategy_state_action_id: 12},
  {strategy_role_id: 2, strategy_state_action_id: 27},
  {strategy_role_id: 2, strategy_state_action_id: 28},
  {strategy_role_id: 2, strategy_state_action_id: 20},
  {strategy_role_id: 2, strategy_state_action_id: 3},
  {strategy_role_id: 2, strategy_state_action_id: 9},
  {strategy_role_id: 2, strategy_state_action_id: 13},
  {strategy_role_id: 2, strategy_state_action_id: 21},
  {strategy_role_id: 2, strategy_state_action_id: 25},
  {strategy_role_id: 2, strategy_state_action_id: 29},
  {strategy_role_id: 2, strategy_state_action_id: 4},
  {strategy_role_id: 2, strategy_state_action_id: 10},
  {strategy_role_id: 2, strategy_state_action_id: 14},
  {strategy_role_id: 2, strategy_state_action_id: 5},
  {strategy_role_id: 2, strategy_state_action_id: 6},
  {strategy_role_id: 2, strategy_state_action_id: 7},
  {strategy_role_id: 3, strategy_state_action_id: 1},
  {strategy_role_id: 3, strategy_state_action_id: 2},
  {strategy_role_id: 3, strategy_state_action_id: 27},
  {strategy_role_id: 3, strategy_state_action_id: 28},
  {strategy_role_id: 3, strategy_state_action_id: 3},
  {strategy_role_id: 3, strategy_state_action_id: 4},
  {strategy_role_id: 3, strategy_state_action_id: 5},
  {strategy_role_id: 3, strategy_state_action_id: 6},
  {strategy_role_id: 3, strategy_state_action_id: 7}
])
Sipity::Models::Role.create!([
  {name: "creating_user", description: nil},
  {name: "etd_reviewing", description: nil},
  {name: "advising", description: nil}
])
Sipity::Models::Work.create!([
  {id: '1', title: "Hello", work_type: "doctoral_dissertation"}
])
Sipity::Models::WorkType.create!([
  {name: "doctoral_dissertation", description: nil}
])
