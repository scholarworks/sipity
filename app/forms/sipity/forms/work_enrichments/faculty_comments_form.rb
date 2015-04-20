module Sipity
  module Forms
    module WorkEnrichments
      # Responsible for capturing and validating information for faculty comments
      class FacultyCommentsForm < Forms::WorkEnrichmentForm
        def initialize(attributes = {})
          super
          self.course = attributes.fetch(:course) { course_from_work }
          self.nature_of_supervision = attributes.fetch(:nature_of_supervision) { nature_of_supervision_from_work }
          self.supervising_semester = attributes.fetch(:supervising_semester) { supervising_semester_from_work }
          self.quality_of_research = attributes.fetch(:quality_of_research) { quality_of_research_from_work }
          self.use_of_library_resources = attributes.fetch(:use_of_library_resources) { use_of_library_resources_from_work }
        end

        attr_accessor :course, :nature_of_supervision, :quality_of_research, :use_of_library_resources
        private(:course=, :nature_of_supervision=, :quality_of_research=, :use_of_library_resources=)

        attr_reader :supervising_semester

        validates :course, presence: true
        validates :nature_of_supervision, presence: true
        validates :quality_of_research, presence: true
        validates :use_of_library_resources, presence: true

        include Hydra::Validations
        validates :supervising_semester, presence: true

        private

        def supervising_semester=(values)
          @supervising_semester = to_array_without_empty_values(values)
        end

        def save(requested_by:)
          super do
            update_course
            update_nature_of_supervision
            update_supervising_semester
            update_quality_of_research
            update_use_of_library_resources
          end
        end

        def update_course
          repository.update_work_attribute_values!(work: work, key: 'course', values: course)
        end

        def update_nature_of_supervision
          repository.update_work_attribute_values!(work: work, key: 'nature_of_supervision', values: nature_of_supervision)
        end

        def update_supervising_semester
          repository.update_work_attribute_values!(work: work, key: 'supervising_semester', values: supervising_semester)
        end

        def update_quality_of_research
          repository.update_work_attribute_values!(work: work, key: 'quality_of_research', values: quality_of_research)
        end

        def update_use_of_library_resources
          repository.update_work_attribute_values!(work: work, key: 'use_of_library_resources', values: use_of_library_resources)
        end

        def course_from_work
          repository.work_attribute_values_for(work: work, key: 'course')
        end

        def nature_of_supervision_from_work
          repository.work_attribute_values_for(work: work, key: 'nature_of_supervision')
        end

        def supervising_semester_from_work
          repository.work_attribute_values_for(work: work, key: 'supervising_semester')
        end

        def quality_of_research_from_work
          repository.work_attribute_values_for(work: work, key: 'quality_of_research')
        end

        def use_of_library_resources_from_work
          repository.work_attribute_values_for(work: work, key: 'use_of_library_resources')
        end

        def to_array_without_empty_values(value)
          Array.wrap(value).select(&:present?)
        end
      end
    end
  end
end
