module Sipity
  module Jobs
    module Etd
      # Responsible for performing an action on a work. In many ways this
      # mimics how the Controller interacts with the runner layer.
      #
      # @see Sipity::Controllers::WorkSubmissionsController
      class PerformActionForWorkJob
        def self.call(**keywords)
          new(**keywords).call
        end

        def initialize(work_id:, processing_action_name:, requested_by:, **keywords)
          self.work_id = work_id
          self.requested_by = requested_by
          self.processing_action_name = processing_action_name
          assign_attributes_from(keywords: keywords)
          set_context!
        end

        def call
          _status, _returned_object = runner.call(
            context, work_id: work_id, processing_action_name: processing_action_name, attributes: attributes
          )
          # TODO: There is no handling of status; What should be done?
        end

        private

        def assign_attributes_from(keywords:)
          [:attributes, :context_builder, :runner].each do |attribute_name|
            send("#{attribute_name}=", keywords.fetch(attribute_name) { send("default_#{attribute_name}") })
          end
        end

        attr_accessor :work_id, :requested_by, :processing_action_name

        attr_reader :context

        def set_context!
          @context = context_builder.call(requested_by: requested_by)
        end

        attr_accessor :attributes

        def default_attributes
          {}
        end

        attr_accessor :context_builder

        def default_context_builder
          require 'sipity/command_line_context' unless defined?(Sipity::CommandLineContext)
          Sipity::CommandLineContext.method(:new)
        end

        attr_accessor :runner

        def default_runner
          require 'sipity/runners/work_submissions_runners' unless defined?(Sipity::Runners::WorkSubmissionsRunners::CommandAction)
          Sipity::Runners::WorkSubmissionsRunners::CommandAction.method(:run)
        end
      end
    end
  end
end
