require "rails_helper"

module Sipity
  RSpec.describe 'validate work_type configuration' do
    DIRECTORY_NAME = File.expand_path('../../../../app/data_generators/sipity/data_generators/work_types', __FILE__)
    Dir.glob(File.join(DIRECTORY_NAME, '*.json')).each do |filename|
      context File.basename(filename).to_s do
        let!(:json) { JSON.parse(File.read(filename)) }
        let!(:work_area_slug) { File.basename(filename, '.config.json').sub('_work_types', '') }
        let(:work_area) { Models::WorkArea.new(slug: work_area_slug) }
        it 'verifies the configuration (e.g. forms, roles, and templates)' do
          defined_roles = Set.new
          defined_actions = Set.new
          defined_templates = Set.new
          json['work_types'].each do |work_type|
            work_type.fetch('strategy_permissions', []).each do |permission|
              defined_roles << permission.fetch('role')
            end
            work_type.fetch('actions').each do |action|
              action_name = action.fetch("name")
              if action_name != Models::Processing::StrategyAction::START_A_SUBMISSION
                defined_actions << action_name
                defined_templates << action_name unless action.key?('transition_to')
              end
              action.fetch("from_states", []).each do |state|
                defined_roles += Array.wrap(state.fetch("roles"))
              end
            end
          end
          validate_defined_roles(roles: defined_roles)
          validate_defined_actions(actions: defined_actions)
          validate_defiend_template_names(template_names: defined_templates)
        end
      end

      def validate_defined_roles(roles:)
        defined_roles = roles.to_a.sort
        intersection_of_valid_roles = (Sipity::Models::Role.names.keys & defined_roles).sort
        expect(defined_roles).to(
          eq(intersection_of_valid_roles), "Expected #{defined_roles.inspect} to all exist in #{intersection_of_valid_roles.inspect}"
        )
      end

      def validate_defined_actions(actions:)
        expect do
          actions.each { |action| Sipity::Forms::WorkSubmissions.find_the_form(work_area: work_area, processing_action_name: action) }
        end.to_not raise_error
      end

      def validate_defiend_template_names(template_names:)
        template_root = Rails.root.join('app/views/sipity/controllers/work_submissions')
        template_names.each do |template_name|
          # Because the action names go through singularization throughout the request flow; Need a citation but that appears to be an
          # implementation detail
          template_name = Conversions::ConvertToProcessingActionName.call(template_name).singularize
          possible_templates = []
          possible_templates << template_root.join(work_area_slug, "#{template_name}.html.curly")
          possible_templates << template_root.join(work_area_slug, "#{template_name}.html.erb")
          possible_templates << template_root.join('core', "#{template_name}.html.curly")
          possible_templates << template_root.join('core', "#{template_name}.html.erb")
          possible_templates << template_root.join("#{template_name}.html.erb")
          possible_templates << template_root.join("#{template_name}.html.curly")
          expect(possible_templates.any?(&:exist?)).to(
            eq(true), "Expected one of the following templates to exist: #{possible_templates.map(&:to_s)}"
          )
        end
      end
    end
  end
end
