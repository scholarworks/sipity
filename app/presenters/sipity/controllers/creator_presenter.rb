require 'sipity/controllers/translation_assistant'

module Sipity
  module Controllers
    # Responsible for presenting a collaborator.
    class CreatorPresenter < Curly::Presenter
      presents :creator

      def initialize(context, options = {})
        # Because the keys could be string or symbol
        self.work_submission = options.fetch('work_submission') { options.fetch(:work_submission) }
        super
      end

      def label(identifier)
        TranslationAssistant.call(scope: :predicates, subject: work_submission, object: identifier, predicate: :label)
      end

      def name
        creator.to_s
      end

      private

      attr_accessor :work_submission
      attr_reader :creator
    end
  end
end
