module Sipity
  module Controllers
    module WorkAreas
      # Responsible for presenting a work area
      class ShowPresenter < Curly::Presenter
        presents :work_area

        def initialize(context, options = {})
          self.repository = options.delete(:repository) { default_repository }
          self.translator = options.delete(:translator) { default_translator }
          # Because controller actions may not cooperate and instead set a
          # :view_object.
          options['work_area'] ||= options['view_object']
          super(context, options)
          self.processing_actions = compose_processing_actions
        end

        private

        attr_accessor :processing_actions
        attr_reader :work_area

        public

        def translate(identifier, scope: default_translation_scope, predicate: :label)
          translator.call(scope: scope, subject: work_area, object: identifier, predicate: predicate)
        end

        delegate :name, to: :work_area

        def to_work_area
          work_area
        end

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

        def default_translation_scope
          "processing_actions.show"
        end

        attr_accessor :translator

        def default_translator
          Controllers::TranslationAssistant
        end

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
