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

        ATTRIBUTE_NAMES = [
          :work_area, :requested_by, :repository, :initial_processing_state_name, :work_ingester, :search_criteria_builder,
          :processing_action_name
        ].freeze

        def initialize(**keywords)
          ATTRIBUTE_NAMES.each do |attribute_name|
            send("#{attribute_name}=", keywords.fetch(attribute_name) { send("default_#{attribute_name}") })
          end
          set_search_criteria!
        end

        include Conversions::ConvertToWork
        def call
          repository.find_works_via_search(criteria: search_criteria).each do |work_like|
            work = convert_to_work(work_like)
            work_ingester.call(work_id: work.id, requested_by: requested_by, processing_action_name: processing_action_name)
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
          require 'sipity/jobs/etd/perform_action_for_work_job' unless defined?(Sipity::Jobs::Etd::PerformActionForWorkJob)
          Sipity::Jobs::Etd::PerformActionForWorkJob
        end

        attr_accessor :initial_processing_state_name

        def default_initial_processing_state_name
          'ready_for_ingest'
        end

        attr_accessor :processing_action_name

        def default_processing_action_name
          'submit_for_ingest'
        end

        attr_accessor :work_area

        def default_work_area
          'etd'
        end

        attr_accessor :requested_by

        def default_requested_by
          require 'sipity/data_generators/work_types/etd_generator' unless defined?(DataGenerators::WorkTypes::EtdGenerator::ETD_INGESTORS)
          # Need this to be the "ETD Ingesters" group; Though I'd prefer a Cogitate string going forward
          Sipity::Models::Group.find_by!(name: DataGenerators::WorkTypes::EtdGenerator::ETD_INGESTORS)
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
