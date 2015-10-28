module Sipity
  module Jobs
    module Etd
      # Responsible for managing the ingest of each and every work in the :work_area that is in the :initial_processing_state_name.
      #
      # As these are jobs, I believe that I want the parameters to all be primatives (i.e. a String, an Integer). This way they can
      # be serialized without holding too much state.
      class BulkIngestJob
        def self.call(**keywords)
          new(**keywords).call
        end

        def initialize(work_area: default_work_area, requested_by: default_requested_by, repository: default_repository, **keywords)
          self.initial_processing_state_name = keywords.fetch(:initial_processing_state_name) { default_initial_processing_state_name }
          self.work_ingester = keywords.fetch(:work_ingester) { default_work_ingester }
          self.search_criteria_builder = keywords.fetch(:search_criteria_builder) { default_search_criteria_builder }
          self.requested_by = requested_by
          self.repository = repository
          self.work_area = work_area
          set_search_criteria!
        end

        include Conversions::ConvertToWork
        def call
          repository.find_works_via_search(criteria: search_criteria).each do |work_like|
            work = convert_to_work(work_like)
            work_ingester.call(work_id: work.id, requested_by: requested_by)
          end
        end

        private

        attr_reader :search_criteria

        def set_search_criteria!
          @search_criteria = search_criteria_builder.call(
            user: requested_by, processing_state: initial_processing_state_name, work_area: work_area, page: :all
          )
        end

        attr_accessor :search_criteria_builder

        def default_search_criteria_builder
          require 'sipity/parameters/search_criteria_for_works_parameter' unless defined?(Parameters::SearchCriteriaForWorksParameter)
          Parameters::SearchCriteriaForWorksParameter.method(:new)
        end

        attr_accessor :work_ingester

        def default_work_ingester
          ->(*) {}
        end

        attr_accessor :initial_processing_state_name

        def default_initial_processing_state_name
          'ready_for_ingest'
        end

        attr_accessor :work_area

        def default_work_area
          'etd'
        end

        attr_accessor :requested_by

        def default_requested_by
          require 'sipity/data_generators/work_types/etd_generator' unless defined?(DataGenerators::WorkTypes::EtdGenerator::ETD_INGESTORS)
          DataGenerators::WorkTypes::EtdGenerator::ETD_INGESTORS
        end

        attr_accessor :repository

        def default_repository
          require 'sipity/query_repository' unless defined?(Sipity::QueryRepository)
          Sipity::QueryRepository.new
        end
      end
    end
  end
end
