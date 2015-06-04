module Sipity
  module Forms
    module WorkSubmissions
      module Core
        # Responsible for "debugging" a Work.
        class DebugForm < Decorators::ComparableSimpleDelegator
          self.base_class = Sipity::Models::Work
          class_attribute :policy_enforcer
          self.policy_enforcer = Sipity::Policies::WorkPolicy

          def initialize(work:, processing_action_name:, **_keywords)
            self.work = work
            self.processing_action_name = processing_action_name
            super(work)
          end

          attr_reader :processing_action_name

          delegate :id, to: :work, prefix: :work

          private

          attr_writer :processing_action_name
          attr_accessor :work
        end
      end
    end
  end
end
