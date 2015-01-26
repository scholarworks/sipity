module Sipity
  module Models
    # Persists the configuration for Work Type's todo list.
    class WorkTypeTodoListConfig < ActiveRecord::Base
      self.table_name = 'sipity_work_type_todo_list_configs'
    end
  end
end
