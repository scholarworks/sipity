module Sipity
  module Queries
    # Queries
    module EnrichmentQueries
      # TODO: Consolidate :build_enrichment_form and
      #   :build_create_describe_work_form
      #
      # TODO: This is the wrong form, but works to solve the specified test.
      def build_enrichment_form(attributes = {})
        enrichment_type = attributes.fetch(:enrichment_type)
        builder = begin
          case enrichment_type
          when 'attach' then Forms::AttachFilesToWorkForm
          when 'describe' then Forms::DescribeWorkForm
          else
            fail Exceptions::EnrichmentNotFoundError, name: enrichment_type, container: 'EnrichmentTypes(Virtual)'
          end
        end

        builder.new(attributes)
      end

      def build_enrichment_todo_list(options = {})
        entity = options.fetch(:entity)
        # REVIEW: This is a concension for the existing behavior, it will change
        #   but I need to sever that connection. The question is when this
        #   information should be assigned. The TODO subsystem is based on
        #   entity and user, so I need to explore how that will get set.
        Decorators::TodoList.new(entity: entity) do |list|
          list.add_to(set: 'required', name: 'attach', state: 'incomplete')
          list.add_to(set: 'required', name: 'describe', state: 'incomplete')
        end
      end
      module_function :build_enrichment_todo_list
      public :build_enrichment_todo_list
    end
  end
end
