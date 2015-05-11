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

        def render_enrichment_action_set(identifier)
          object = enrichment_action_set_for(identifier: identifier)
          render partial: "enrichment_action_set", object: object if object.present?
        end

        delegate(
          :resourceful_actions, :resourceful_actions?,
          :enrichment_actions, :enrichment_actions?,
          :state_advancing_actions, :state_advancing_actions?,
          :enrichment_action_set_for, :can_advance_processing_state?,
          to: :processing_actions
        )

        # TODO: work_type, processing_state should be translated
        delegate :id, to: :work_submission, prefix: :work
        delegate :title, :work_type, to: :work_submission

        def processing_state
          work_submission.processing_state.to_s
        end

        def label(identifier)
          # TODO: Is there a better way to namespace this?
          Models::Work.human_attribute_name(identifier)
        end

        def section(identifier)
          I18n.t("sipity/works.processing_action_names.#{processing_action_name}.#{identifier}")
        end

        private

        def processing_action_name
          # TODO: Magic string here!
          'show'
        end

        attr_reader :work_submission

        attr_accessor :processing_actions

        def compose_processing_actions
          ComposableElements::ProcessingActionsComposer.new(user: current_user, entity: work_submission)
        end
      end
    end
  end
end
