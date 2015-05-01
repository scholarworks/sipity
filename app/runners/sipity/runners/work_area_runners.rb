module Sipity
  module Runners
    module WorkAreaRunners
      # Responsible for responding with a work area
      class Show < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :default
        self.action_name = :show?

        def run(work_area_slug:)
          work_area = repository.find_work_area_by(slug: work_area_slug)
          authorization_layer.enforce!(action_name => work_area) do
            callback(:success, work_area)
          end
        end
      end

      # The general handler for general query actions (show may be a customized
      # case).
      class QueryAction < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :default

        def run(work_area_slug:, processing_action_name:, attributes: {})
          work_area = repository.find_work_area_by(slug: work_area_slug)
          form = repository.build_processing_action_form(
            entity: work_area, processing_action_name: processing_action_name, attributes: attributes
          )
          authorization_layer.enforce!(processing_action_name => form) do
            callback(:success, form)
          end
        end
      end

      # The general handler for all command actions
      class CommandAction < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :default

        def run(work_area_slug:, processing_action_name:, attributes: {})
          work_area = repository.find_work_area_by(slug: work_area_slug)
          form = repository.build_processing_action_form(
            entity: work_area, processing_action_name: processing_action_name, attributes: attributes
          )
          authorization_layer.enforce!(processing_action_name => form) do
            form.submit(requested_by: current_user) ? callback(:success, work_area) : callback(:failure, form)
          end
        end
      end
    end
  end
end
