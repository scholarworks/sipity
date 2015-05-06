module Sipity
  module Services
    # Encapsulation of what goes on when a new work is created.
    class CreateWorkService
      def self.call(**attributes)
        new(**attributes).call
      end

      def initialize(pid_minter: default_pid_minter, repository: default_repository, **attributes)
        self.pid_minter = pid_minter
        self.repository = repository
        self.submission_window = attributes.delete(:submission_window) { default_submission_window }
        self.attributes = attributes
      end

      def call
        create_the_work!
        associated_the_work_and_submission_window!
        create_the_work_processing_entity!
        work
      end

      private

      def create_the_work!
        @work = Models::Work.create!(attributes)
      end

      def associated_the_work_and_submission_window!
        Models::WorkSubmission.create!(
          work_id: work.id, submission_window_id: submission_window.id, work_area_id: submission_window.work_area_id
        )
      end

      def create_the_work_processing_entity!
        # Why did I not use dependency injection?
        # Because, in my estimation, there is a harder coupling going on. Hence
        # the yielded block.
        DataGenerators::FindOrCreateWorkType.call(name: attributes.fetch(:work_type)) do |_work_type, processing_strategy, strategy_state|
          work.create_processing_entity!(strategy_state_id: strategy_state.id, strategy_id: processing_strategy.id)
        end
      end

      attr_accessor :pid_minter, :repository, :attributes, :submission_window
      attr_reader :work

      def default_repository
        CommandRepository.new
      end

      WORK_ATTRIBUTES_FOR_CREATE = [:title, :work_publication_strategy, :work_type].freeze

      def attributes=(input)
        @attributes = input.slice(*WORK_ATTRIBUTES_FOR_CREATE).merge(id: pid_minter.call)
      end

      def default_pid_minter
        Rails.application.config.default_pid_minter
      end

      def default_submission_window
        # This is a conceit to the tests; It is also indicative of a greater problem.
        # TODO: Remove the default behavior; Its presumptive and an expensive test.
        #   Also as we look at things, pay attention to the deprecation warnings.
        #   Those methods may be doing too much and not operating in isolation.
        submission_window_slug = Forms::Etd::StartASubmissionForm::DEFAULT_SUBMISSION_WINDOW_SLUG
        work_area_slug = Forms::Etd::StartASubmissionForm::DEFAULT_WORK_AREA_SLUG
        Sipity::DataGenerators::FindOrCreateWorkArea.call(name: 'Electronic Thesis and Dissertation', slug: work_area_slug) do |work_area|
          Sipity::DataGenerators::FindOrCreateSubmissionWindow.call(slug: submission_window_slug, work_area: work_area)
        end
        repository.find_submission_window_by(
          slug: submission_window_slug,
          work_area: work_area_slug
        )
      end
      # The submission window will be a requirement after ULRA is added.
      deprecate :default_submission_window
    end
  end
end
