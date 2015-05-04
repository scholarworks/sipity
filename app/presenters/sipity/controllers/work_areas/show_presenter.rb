module Sipity
  module Controllers
    module WorkAreas
      # Responsible for presenting a work area
      class ShowPresenter < Curly::Presenter
        presents :work_area

        def initialize(context, options = {})
          self.repository = options.delete(:repository) || default_repository
          # Because controller actions may not cooperate and instead set a
          # :view_object.
          options['work_area'] ||= options['view_object']
          super
        end

        private

        attr_reader :work_area

        public

        def submission_windows
          repository.scope_proxied_objects_for_the_user_and_proxy_for_type(
            user: current_user, proxy_for_type: Models::SubmissionWindow, where: { work_area: work_area }
          )
        end

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

        def default_repository
          QueryRepository.new
        end
      end
    end
  end
end
