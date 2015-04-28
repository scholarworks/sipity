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
        self.attributes = attributes
      end

      def call
        create_the_work!
        create_the_work_processing_entity!
        work
      end

      private

      def create_the_work!
        @work = Models::Work.create!(attributes)
      end

      def create_the_work_processing_entity!
        # Why did I not use dependency injection?
        # Because, in my estimation, there is a harder coupling going on. Hence
        # the yielded block.
        DataGenerators::FindOrCreateWorkType.call(name: attributes.fetch(:work_type)) do |_work_type, processing_strategy, strategy_state|
          work.create_processing_entity!(strategy_state_id: strategy_state.id, strategy_id: processing_strategy.id)
        end
      end

      attr_accessor :pid_minter, :repository, :attributes
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
    end
  end
end
