module Sipity
  module Models
    # Persists the configuration for Work Type's todo list.
    class WorkTypeTodoListConfig < ActiveRecord::Base
      self.table_name = 'sipity_work_type_todo_list_configs'

      ENRICHMENT_GROUP_REQUIRED = 'required'.freeze
      ENRICHMENT_GROUP_OPTIONAL = 'optional'.freeze

      enum(
        enrichment_group: {
          ENRICHMENT_GROUP_REQUIRED => ENRICHMENT_GROUP_REQUIRED,
          ENRICHMENT_GROUP_OPTIONAL => ENRICHMENT_GROUP_OPTIONAL
        }
      )
    end
  end
end
