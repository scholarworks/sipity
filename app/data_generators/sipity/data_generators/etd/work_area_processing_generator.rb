module Sipity
  module DataGenerators
    module Etd
      # Responsible for generating the work types within the ETD.
      class WorkAreaProcessingGenerator
        def self.call(**keywords)
          new(**keywords).call
        end

        def initialize(work_area:, processing_strategy:, **keywords)
          self.work_area = work_area
          self.processing_strategy = processing_strategy
          self.work_area_viewers = keywords.fetch(:work_area_viewers) { default_work_area_viewers }
          self.work_area_viewer_role = keywords.fetch(:work_area_viewer_role) { default_work_area_viewer_role }
        end

        private

        attr_accessor :processing_strategy
        attr_reader :work_area, :work_area_viewer_role, :work_area_viewers

        def work_area=(input)
          @work_area = PowerConverter.convert(input, to: :work_area)
        end

        def default_work_area_viewer_role
          Models::Role::WORK_AREA_VIEWER
        end

        def work_area_viewer_role=(input)
          @work_area_viewer_role = Conversions::ConvertToRole.call(input)
        end

        def work_area_viewers=(input)
          @work_area_viewers = Array.wrap(input).map {|i| Conversions::ConvertToProcessingActor.call(i) }
        end

        def default_work_area_viewers
          Models::Group.all_registered_users
        end

        public

        def call
          strategy_role = associate_authenticated_user_with_work_area!
          allow_authenticated_user_to_view_the_work_area!(strategy_role: strategy_role)
        end

        private

        # TODO: Extract associate user to role and grant permission to these actions for the state

        def associate_authenticated_user_with_work_area!
          strategy_role = Models::Processing::StrategyRole.find_or_create_by!(role: work_area_viewer_role, strategy: processing_strategy)
          work_area_viewers.each do |viewer|
            Models::Processing::EntitySpecificResponsibility.find_or_create_by!(
              strategy_role: strategy_role,
              entity: work_area.processing_entity,
              actor: viewer
            )
          end
          strategy_role
        end

        PERMITTED_WORK_AREA_VIEWER_ACTIONS = ['show'].freeze
        def allow_authenticated_user_to_view_the_work_area!(strategy_role:)
          PERMITTED_WORK_AREA_VIEWER_ACTIONS.each do |action_name|
            strategy_action = Models::Processing::StrategyAction.find_or_create_by!(
              strategy: processing_strategy, name: action_name, allow_repeat_within_current_state: true
            )
            state_action = Models::Processing::StrategyStateAction.find_or_create_by!(
              strategy_action: strategy_action, originating_strategy_state: processing_strategy.initial_strategy_state
            )
            Models::Processing::StrategyStateActionPermission.find_or_create_by!(
              strategy_role: strategy_role, strategy_state_action: state_action
            )
          end
        end
      end
    end
  end
end
