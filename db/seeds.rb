# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# Environment variables (ENV['...']) can be set in the file config/application.yml.
# See http://railsapps.github.io/rails-environment-variables.html

# A helpful method for making sure that we are building the nested data correctly.
def find_or_initialize_or_create!(attributes = {})
  context = attributes.fetch(:context)
  receiver = attributes.fetch(:receiver)
  method_name = context.persisted? ? :find_or_create_by! : :find_or_initialize_by
  receiver.send(method_name, attributes.except(:context, :receiver))
end

ActiveRecord::Base.transaction do
  $stdout.puts 'Creating Work Types...'
  work_types = {}
  Sipity::Models::WorkType.valid_names.each do |work_type_name|
    work_types[work_type_name] = Sipity::Models::WorkType.find_or_create_by!(name: work_type_name)
  end


  graduate_school_group = Sipity::Models::Group.find_or_create_by!(name: 'Graduate School Reviewers')
  graduate_school_actor = Sipity::Conversions::ConvertToProcessingActor.call(graduate_school_group)

  $stdout.puts 'Creating ETD Reviewer Role...'
  roles = {}

  [
    'creating_user',
    'etd_reviewer',
    'advisor'
  ].each do |role_name|
    roles[role_name] = Sipity::Models::Role.find_or_create_by!(name: role_name)
  end

  $stdout.puts 'Creating copyright names...'
  content_licenses = [
    ['copyright', 'Attribution 3.0 United States', 'http://creativecommons.org/licenses/by/3.0/us/'],
    ['copyright', 'Attribution-ShareAlike 3.0 United States', 'http://creativecommons.org/licenses/by-sa/3.0/us/'],
    ['copyright', 'Attribution-NonCommercial 3.0 United States', 'http://creativecommons.org/licenses/by-nc/3.0/us/'],
    ['copyright', 'Attribution-NoDerivs 3.0 United States', 'http://creativecommons.org/licenses/by-nd/3.0/us/'],
    ['copyright', 'Attribution-NonCommercial-NoDerivs 3.0 United States', 'http://creativecommons.org/licenses/by-nc-nd/3.0/us/'],
    ['copyright', 'Attribution-NonCommercial-ShareAlike 3.0 United States', 'http://creativecommons.org/licenses/by-nc-sa/3.0/us/'],
    ['copyright', 'Public Domain Mark 1.0', 'http://creativecommons.org/publicdomain/mark/1.0/'],
    ['copyright', 'CC0 1.0 Universal', 'http://creativecommons.org/publicdomain/zero/1.0/'],
    ['copyright', 'All rights reserved', 'All rights reserved']
  ]
  content_licenses.each do |predicate_name, term_label, term_uri|
    Sipity::Models::SimpleControlledVocabulary.find_or_create_by!(
    predicate_name: predicate_name, term_label: term_label, term_uri: term_uri)
  end


  $stdout.puts 'Creating degree names...'
  [
    ['degree', 'Doctor of Musical Arts', 'DMA'],
    ['degree', 'Doctor of Philosophy', 'PhD'],
    ['degree', 'Master of Arts', 'MA'],
    ['degree', 'Master of Fine Arts', 'MFA'],
    ['degree', 'Master of Medieval Studies', 'MMS'],
    ['degree', 'Master of Science', 'MS'],
    ['degree', 'Master of Science in Aerospace Engineering', 'MSAE'],
    ['degree', 'Master of Science in Bioengineering', 'MSBioE'],
    ['degree', 'Master of Science in Chemical Engineering', 'MSChE'],
    ['degree', 'Master of Science in Civil Engineering', 'MSCE'],
    ['degree', 'Master of Science in Computer Science and Engineering', 'MSCSE'],
    ['degree', 'Master of Science in Earth Sciences', 'MSES'],
    ['degree', 'Master of Science in Electrical Engineering', 'MSEE'],
    ['degree', 'Master of Science in Environmental Engineering', 'MSEnvE'],
    ['degree', 'Master of Science in Geological Sciences', 'MSGS'],
    ['degree', 'Master of Science in Interdisciplinary Mathematics', 'MSIM'],
    ['degree', 'Master of Science in Mechanical Engineering', 'MSME'],
    ['program_name', 'Aerospace and Mechanical Engineering', 'AME'],
    ['program_name', 'Anthropology', 'ANTH'],
    ['program_name', 'Applied and Computational Mathematics and Statistics', 'ACMS'],
    ['program_name', 'Art, Art History, and Design', 'ART'],
    ['program_name', 'Bioengineering', 'BIOE'],
    ['program_name', 'Biological Sciences', 'BIOS'],
    ['program_name', 'Chemical and Biomolecular Engineering', 'CBE, CHEG'],
    ['program_name', 'Civil and Environmental Engineering and Earth Sciences', 'Civil Engineering and Geological Sciences, CEEES, CEGS'],
    ['program_name', 'Chemistry', 'CHEM'],
    ['program_name', 'Classics', 'CLAS'],
    ['program_name', 'Computer Science and Engineering', 'CSE'],
    ['program_name', 'Creative Writing', 'CW, ENGL-CW'],
    ['program_name', 'Economics', 'Economics and Econometrics, ECON'],
    ['program_name', 'Early Christian Studies', 'ECS'],
    ['program_name', 'Electrical Engineering', 'EE'],
    ['program_name', 'English', 'ENGL'],
    ['program_name', 'History', 'HIST'],
    ['program_name', 'History and Philosophy of Science', 'HPS'],
    ['program_name', 'Integrated Biomedical Sciences', 'IBMS'],
    ['program_name', 'Peace Studies', 'PEACE, IIPS'],
    ['program_name', 'Law', nil],
    ['program_name', 'Literature', 'PhD in Literature, LIT'],
    ['program_name', 'Mathematics', 'MATH'],
    ['program_name', 'Medieval Studies', 'Medieval Institute, MI, MS'],
    ['program_name', 'Philosophy', 'PHIL'],
    ['program_name', 'Physics', 'PHYS'],
    ['program_name', 'Political Science', 'POLS'],
    ['program_name', 'Psychology', 'PSY'],
    ['program_name', 'Romance Languages and Literatures', 'ROML'],
    ['program_name', 'Sacred Music', 'SACM'],
    ['program_name', 'Sociology', 'SOC'],
    ['program_name', 'Theology', 'THEO']
  ].each do |predicate_name, term_label, subject_searchable_terms|
    if vocab = Sipity::Models::SimpleControlledVocabulary.find_by(predicate_name: predicate_name, term_label: term_label)
      if vocab.term_uri !~ %r{\A\w+://\w}
        vocab.update(term_uri: nil)
      end
    else
      Sipity::Models::SimpleControlledVocabulary.create!(predicate_name: predicate_name, term_label: term_label)
    end
  end

  $stdout.puts 'Creating ETD State Diagram...'
  ['doctoral_dissertation', 'master_thesis'].each do |work_type_name|
    work_types.fetch(work_type_name).find_or_initialize_default_processing_strategy do |etd_strategy|
      etd_strategy_roles = {}

      [
        'creating_user',
        'etd_reviewer',
        'advisor'
      ].each do |role_name|
        etd_strategy_roles[role_name] = find_or_initialize_or_create!(
          context: etd_strategy,
          receiver: etd_strategy.strategy_roles,
          role: roles.fetch(role_name)
        )
      end

      etd_reviewer = etd_strategy_roles.fetch('etd_reviewer')

      find_or_initialize_or_create!(
        context: etd_reviewer,
        receiver: etd_reviewer.strategy_responsibilities,
        actor: graduate_school_actor
      )

      etd_states = {}
      [
        'new',
        'under_advisor_review',
        'advisor_changes_requested',
        'under_grad_school_review',
        'grad_school_changes_requested',
        'ready_for_ingest'
      ].each do |state_name|
        etd_states[state_name] = find_or_initialize_or_create!(
          context: etd_strategy,
          receiver: etd_strategy.strategy_states,
          name: state_name
        )
      end

      etd_actions = {}
      [
        { action_name: 'show', seq: 1 },
        { action_name: 'destroy', seq: 2 },
        { action_name: 'describe', seq: 1 },
        { action_name: 'collaborators', seq: 2 },
        { action_name: 'attach', seq: 3 },
        { action_name: 'defense_date', seq: 4 },
        { action_name: 'search_terms', seq: 5 },
        { action_name: 'degree', seq: 6 },
        { action_name: 'access_policy', seq: 7 },
        { action_name: 'submit_for_review', resulting_state_name: 'under_advisor_review', seq: 1, allow_repeat_within_current_state: false },
        { action_name: 'advisor_signoff', resulting_state_name: 'under_grad_school_review', seq: 1, allow_repeat_within_current_state: false },
        { action_name: 'signoff_on_behalf_of', resulting_state_name: 'under_grad_school_review', seq: 1, allow_repeat_within_current_state: false },
        { action_name: 'advisor_requests_change', resulting_state_name: 'advisor_changes_requested', seq: 2, allow_repeat_within_current_state: false },
        { action_name: 'request_change_on_behalf_of', resulting_state_name: 'advisor_changes_requested', seq: 3, allow_repeat_within_current_state: false },
        { action_name: 'respond_to_advisor_request', resulting_state_name: 'under_advisor_review', seq: 1, allow_repeat_within_current_state: false  },
        { action_name: 'respond_to_grad_school_request', resulting_state_name: 'under_grad_school_review', seq: 1, allow_repeat_within_current_state: false },
        { action_name: 'grad_school_requests_change', resulting_state_name: 'grad_school_changes_requested', seq: 2, allow_repeat_within_current_state: false },
        { action_name: 'grad_school_signoff', resulting_state_name: 'ready_for_ingest',seq: 1, allow_repeat_within_current_state: false }
      ].each do |structure|
        action_name = structure.fetch(:action_name)
        resulting_state = structure[:resulting_state_name] ? etd_states.fetch(structure[:resulting_state_name]) : nil
        action = find_or_initialize_or_create!(
          context: etd_strategy,
          receiver: etd_strategy.strategy_actions,
          name: action_name
        )

        # Because the objects are being instantiated differently, I need to make
        # sure to capture the default action_type.
        action.resulting_strategy_state = resulting_state
        if action.persisted?
          action.update(
            presentation_sequence: structure.fetch(:seq), resulting_strategy_state: resulting_state,
            action_type: action.default_action_type, allow_repeat_within_current_state: structure.fetch(:allow_repeat_within_current_state, true)
          )
        else
          action.presentation_sequence = structure.fetch(:seq)
          action.allow_repeat_within_current_state = structure.fetch(:allow_repeat_within_current_state, true)
          # Because the objects are being instantiated differently, I need to make
          # sure to capture the default action_type.
          action.action_type = action.default_action_type
        end
        etd_actions[action_name] = action
      end

      [
        { action: 'advisor_requests_change', analogous_to: 'advisor_signoff' }
      ].each do |options|
        action = etd_actions.fetch(options.fetch(:action))
        analogous_to = etd_actions.fetch(options.fetch(:analogous_to))
        find_or_initialize_or_create!(
          context: action,
          receiver: action.base_element_for_strategy_actions_analogues,
          analogous_to_strategy_action: analogous_to
        )
      end

      pre_requisite_states =       {
        'submit_for_review' => ['describe', 'degree', 'attach', 'collaborators', 'access_policy']
      }

      if work_type_name == 'doctoral_dissertation'
        pre_requisite_states['submit_for_review'] << 'defense_date'
      end

      pre_requisite_states.each do |guarded_action_name, prereq_action_names|
        guarded_action = etd_actions.fetch(guarded_action_name)
        Array.wrap(prereq_action_names).each do |prereq_action_name|
          prereq_action = etd_actions.fetch(prereq_action_name)
          find_or_initialize_or_create!(
            context: guarded_action,
            receiver: guarded_action.requiring_strategy_action_prerequisites,
            prerequisite_strategy_action: prereq_action
          )
        end
      end


      [
        [
          ['new'],
          ['submit_for_review'],
          ['creating_user']
        ],[
          ['advisor_changes_requested'],
          ['respond_to_advisor_request'],
          ['creating_user']
        ],[
          ['grad_school_changes_requested'],
          ['respond_to_grad_school_request'],
          ['creating_user']
        ],[
          ['new', 'under_advisor_review', 'advisor_changes_requested', 'under_grad_school_review', 'grad_school_changes_requested', 'ready_for_ingest'],
          ['show'],
          ['creating_user', 'advisor', 'etd_reviewer'],
        ],[
          ['new', 'advisor_changes_requested'],
          ['defense_date','degree', 'access_policy', 'describe','search_terms', 'attach', 'collaborators'],
          ['creating_user', 'etd_reviewer']
        ],[
          ['new'],
          ['destroy'],
          ['creating_user', 'etd_reviewer']
        ],[
          ['under_advisor_review', 'advisor_changes_requested', 'under_grad_school_review', 'grad_school_changes_requested'],
          ['destroy'],
          ['etd_reviewer']
        ],[
          ['under_advisor_review'],
          ['advisor_signoff'],
          ['advisor']
        ],[
          ['under_advisor_review'],
          ['signoff_on_behalf_of', 'request_change_on_behalf_of'],
          ['etd_reviewer']
        ],[
          ['under_advisor_review'],
          ['advisor_requests_change'],
          ['etd_reviewer', 'advisor']
        ],[
          ['under_grad_school_review'],
          ['grad_school_requests_change', 'grad_school_signoff'],
          ['etd_reviewer']
        ]
      ].each do |originating_state_names, action_names, role_names|
        Array.wrap(originating_state_names).each do |originating_state_name|
          Array.wrap(action_names).each do |action_name|
            action = etd_actions.fetch(action_name)
            originating_state = etd_states.fetch(originating_state_name)
            event = find_or_initialize_or_create!(
              context: action,
              receiver: action.strategy_state_actions,
              originating_strategy_state: originating_state
            )

            Array.wrap(role_names).each do |role_name|
              strategy_role = etd_strategy_roles.fetch(role_name)
              find_or_initialize_or_create!(
                context: strategy_role,
                receiver: strategy_role.strategy_state_action_permissions,
                strategy_state_action: event
              )
            end
          end
        end
      end

      # Define associated emails by action
      [
        {
          action: 'submit_for_review',
          emails: {
            confirmation_of_submit_for_review: { to: 'creating_user' },
            submit_for_review: { to: ['advisor', 'etd_reviewer'] }
          }
        },
        {
          action: 'advisor_signoff',
          emails: {
            advisor_signoff_is_complete: { to: 'etd_reviewer', cc: 'creating_user' },
            confirmation_of_advisor_signoff_is_complete: { to: 'creating_user' },
          }
        },
        {
          action: 'signoff_on_behalf_of',
          emails: {
            advisor_signoff_is_complete: { to: 'etd_reviewer', cc: 'creating_user' },
            confirmation_of_advisor_signoff_is_complete: { to: 'creating_user' },
          }
        },
        {
          action: 'advisor_requests_change',
          emails: {
            advisor_requests_change: { to: 'creating_user' }
          }
        },
        {
          action: 'request_change_on_behalf_of',
          emails: {
            request_change_on_behalf_of: { to: 'creating_user' }
          }
        },
        {
          action: 'respond_to_advisor_request',
          emails: { respond_to_advisor_request: { to: 'advisor', cc: 'creating_user'} }
        },
        {
          action: 'respond_to_grad_school_request',
          emails: { respond_to_grad_school_request: { to: 'etd_reviewer', cc: 'creating_user'} }
        },
        {
          action: 'grad_school_requests_change',
          emails: { grad_school_requests_change: { to: 'creating_user' } }
        },
        {
          action: 'grad_school_signoff',
          emails: { confirmation_of_grad_school_signoff: { to: ['creating_user', 'grad_school'] } }
        }
      ].each do |email_config|

      end
    end.save!
  end
end
