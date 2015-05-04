module Sipity
  module Controllers
    module SubmissionWindows
      # Responsible for presenting a work area
      class ShowPresenter < SubmissionWindowPresenter
        def resourceful_actions
          @resourceful_actions ||= processing_actions.select(&:resourceful_action?)
        end

        def resourceful_actions?
          resourceful_actions.present?
        end

        def state_advancing_actions
          @state_advancing_actions ||= processing_actions.select(&:state_advancing_action?)
        end

        def state_advancing_actions?
          state_advancing_actions.present?
        end

        def enrichment_actions
          @enrichment_actions ||= processing_actions.select(&:enrichment_action?)
        end

        def enrichment_actions?
          state_advancing_actions.present?
        end

        def processing_state
          work_area.processing_state.to_s
        end

        private

        attr_accessor :repository

        def processing_actions
          @processing_actions ||= repository.scope_permitted_entity_strategy_actions_for_current_state(
            user: current_user, entity: work_area
          )
        end
      end
    end
  end
end
