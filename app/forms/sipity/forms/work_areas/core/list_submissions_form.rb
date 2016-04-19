require 'sipity/forms/processing_form'

module Sipity
  module Forms
    module WorkAreas
      module Core
        # Responsible for finding all work submissions that have are visible to the given user within the given
        # work area.
        class ListSubmissionsForm
          ProcessingForm.configure(form_class: self, base_class: Models::WorkArea, attribute_names: [])
          def initialize(work_area:, requested_by:, **keywords)
            self.work_area = work_area
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
          end

          include ActiveModel::Validations

          def works
            Array.wrap(find_works).map { |work| Models::ExpandedWork.new(work: work, repository: repository) }
          end

          extend Forwardable
          def_delegators :works, :to_json, :as_json, :to_hash

          def search_criteria
            Parameters::SearchCriteriaForWorksParameter.new(user: requested_by, page: :all, work_area: work_area)
          end

          private

          def find_works
            repository.find_works_via_search(criteria: search_criteria)
          end
        end
      end
    end
  end
end
