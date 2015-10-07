require 'sipity/runners/base_runner'
require 'active_record/base'

module Sipity
  module Runners
    # Container for WorkArea related "action" runners
    module WorkAreaRunners
      # :nodoc:
      class CommandQueryAction < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :default

        def run(work_area_slug:, processing_action_name:, attributes: {})
          work_area = repository.find_work_area_by(slug: work_area_slug)
          form = repository.build_work_area_processing_action_form(
            work_area: work_area, processing_action_name: processing_action_name, attributes: attributes, requested_by: current_user
          )
          authorization_layer.enforce!(processing_action_name => form) do
            yield(form, work_area)
          end
        end
      end
      private_constant :CommandQueryAction

      # The general handler for general query actions (show may be a customized
      # case).
      class QueryAction < CommandQueryAction
        def run(work_area_slug:, processing_action_name:, attributes: {})
          super do |form, _work_area|
            callback(:success, form)
          end
        end
      end

      # The general handler for all command actions
      class CommandAction < CommandQueryAction
        def run(work_area_slug:, processing_action_name:, attributes: {})
          super do |form, work_area|
            ActiveRecord::Base.transaction do
              if form.submit
                callback(:success, work_area)
              else
                callback(:failure, form)
              end
            end
          end
        end
      end
    end
  end
end
