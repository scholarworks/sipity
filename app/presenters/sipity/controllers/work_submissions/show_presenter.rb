module Sipity
  module Controllers
    module WorkSubmissions
      # Responsible for "showing" a WorkSubmission
      class ShowPresenter < Curly::Presenter
        presents :work_submission

        def initialize(context, options = {})
          # Because controller actions may not cooperate and instead set a
          # :view_object.
          options['work_submission'] ||= options['view_object']
          super
          self.processing_actions = compose_processing_actions
        end

        delegate(
          :resourceful_actions, :resourceful_actions?,
          :enrichment_actions, :enrichment_actions?,
          :state_advancing_actions, :state_advancing_actions?,
          to: :processing_actions
        )

        delegate :id, to: :work_submission, prefix: :work

        def processing_state
          work_submission.processing_state.to_s
        end

        private

        attr_reader :work_submission

        attr_accessor :processing_actions

        def compose_processing_actions
          ComposableElements::ProcessingActionsComposer.new(user: current_user, entity: work_submission)
        end
      end
    end
  end
end
