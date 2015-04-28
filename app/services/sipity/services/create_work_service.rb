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
        Models::Work.create!(attributes) do |work|
          named_work_type = attributes.fetch(:work_type)
          work_type = Models::WorkType.find_or_create_by!(name: named_work_type)
          # A bit of a weirdness as I splice in the new behavior
          strategy = attributes.fetch(:processing_strategy) { work_type.find_or_initialize_default_processing_strategy.tap(&:save!) }
          strategy_state = attributes.fetch(:processing_strategy_state) { strategy.initial_strategy_state }
          work.build_processing_entity(strategy_state: strategy_state, strategy: strategy)
        end
      end

      private

      attr_accessor :pid_minter, :repository, :attributes
      attr_reader :work

      def default_repository
        CommandRepository.new
      end

      def attributes=(input)
        @attributes = input.slice(:title, :work_publication_strategy, :work_type).merge(id: pid_minter.call)
      end

      def default_pid_minter
        Rails.application.config.default_pid_minter
      end
    end
  end
end
