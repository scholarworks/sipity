module Sipity
  module Forms
    module Core
      module WorkAreas
        # Responsible for "showing" a Work Area.
        #
        # @note This is the result of changing the WorkAreas controller
        #   to be two actions.
        class ShowForm < SimpleDelegator
          class_attribute :policy_enforcer
          self.policy_enforcer = Sipity::Policies::WorkAreaPolicy

          def initialize(work_area:, processing_action_name:, **_keywords)
            self.work_area = work_area
            self.processing_action_name = processing_action_name
            super(work_area)
          end

          attr_reader :processing_action_name

          private

          attr_writer :processing_action_name
          attr_accessor :work_area
        end
      end
    end
  end
end
