module Sipity
  module Controllers
    module WorkAreas
      # Responsible for presenting a work area
      class ShowPresenter < Curly::Presenter
        presents :work_area

        def initialize(context, options = {})
          self.repository = options.delete(:repository) { default_repository }
          # Because controller actions may not cooperate and instead set a
          # :view_object.
          options['work_area'] ||= options['view_object']
          super
          self.processing_actions = compose_processing_actions
        end

        private

        attr_accessor :processing_actions
        attr_reader :work_area

        public

        delegate :name, to: :work_area

        def submission_windows
          @submission_windows ||= repository.scope_proxied_objects_for_the_user_and_proxy_for_type(
            user: current_user, proxy_for_type: Models::SubmissionWindow, where: { work_area: work_area }
          )
        end

        def submission_windows?
          submission_windows.present?
        end

        delegate(
          :resourceful_actions, :resourceful_actions?,
          :enrichment_actions, :enrichment_actions?,
          :state_advancing_actions, :state_advancing_actions?,
          to: :processing_actions
        )

        def processing_state
          work_area.processing_state.to_s
        end

        private

        def compose_processing_actions
          ComposableElements::ProcessingActionsComposer.new(repository: repository, user: current_user, entity: work_area)
        end

        attr_accessor :repository

        def default_repository
          QueryRepository.new
        end
      end
    end
  end
end
