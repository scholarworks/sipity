module Sipity
  module DataGenerators
    # Responsible for finding or creating the corresponding work type and the
    # requisite processing entries.
    #
    # Also consider that the existing tests are using a piecemeal approach
    # to work type creation (and strategy creation). This is a class that
    # can be leveraged instead of a FactoryGirl construct (which would not
    # be leveraged in production).
    #
    # @TODO: With lots of bootstrapping data and complex data interactions, this
    #   class can be used in the test ecosystem to help build a somewhat well
    #   defined and expected WorkType.
    class FindOrCreateWorkType
      def self.call(**keywords, &block)
        new(**keywords).call(&block)
      end

      def initialize(name:)
        self.name = name
      end

      def call
        @work_type = find_or_create_the_work_type!
        strategy_usage = find_or_create_strategy_usage!
        strategy = strategy_usage.strategy
        initial_strategy_state = strategy.initial_strategy_state
        yield(work_type, strategy, initial_strategy_state) if block_given?
      end

      private

      def find_or_create_the_work_type!
        PowerConverter.convert(name, to: :work_type)
      end

      def find_or_create_strategy_usage!
        return work_type.strategy_usage if work_type.strategy_usage
        create_strategy_usage!
      end

      def create_strategy_usage!
        # NOTE: Assumption, each work type has one and only one processing strategy
        #   and it does not vary by submission window.
        strategy = Models::Processing::Strategy.find_or_create_by!(name: "#{work_type.name} processing")
        work_type.create_strategy_usage!(strategy: strategy)
      end

      attr_accessor :name
      attr_reader :work_type
    end
  end
end
