require 'sipity/forms/processing_form'

module Sipity
  module Forms
    module WorkAreas
      module Core
        # Responsible for finding all work submissions that have are visible to the given user within the given
        # work area.
        class ListSubmissionsForm
          ProcessingForm.configure(form_class: self, base_class: Models::WorkArea, attribute_names: [:page])
          def initialize(work_area:, requested_by:, attributes: {}, **keywords)
            self.work_area = work_area
            self.requested_by = requested_by
            self.page = attributes.fetch(:page, 1)
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            initialize_works!
          end

          include ActiveModel::Validations

          attr_reader :works

          extend Forwardable
          def_delegators :expanded_works, :to_json, :as_json, :to_hash

          private

          def expanded_works
            Array.wrap(works).map { |work| Models::ExpandedWork.new(work: work, repository: repository) }
          end

          def search_criteria
            Parameters::SearchCriteriaForWorksParameter.new(user: requested_by, work_area: work_area, page: page)
          end

          def initialize_works!
            @works = repository.find_works_via_search(criteria: search_criteria)
          end
        end
      end
    end
  end
end
