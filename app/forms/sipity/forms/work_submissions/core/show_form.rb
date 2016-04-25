require 'sipity/models/expanded_work'
require 'sipity/query_repository'

module Sipity
  module Forms
    module WorkSubmissions
      module Core
        # Responsible for "showing" a Work.
        #
        # @note This is the result of changing the Work controller
        #   to be two actions.
        class ShowForm < Decorators::ComparableSimpleDelegator
          self.base_class = Models::Work
          class_attribute :policy_enforcer
          self.policy_enforcer = Sipity::Policies::WorkPolicy

          def initialize(work:, processing_action_name:, repository: default_repository, **_keywords)
            self.work = work
            self.processing_action_name = processing_action_name
            self.repository = repository
            # TODO: Remove dependency on WorkDecorator, this is needed for the
            # HTML sanitization/rendering.
            super(decorated_work)
          end

          attr_reader :processing_action_name

          delegate :id, to: :work, prefix: :work
          delegate :to_hash, :as_json, :to_json, to: :expanded_work

          private

          def expanded_work
            Models::ExpandedWork.new(work: work)
          end

          def decorated_work
            Sipity::Decorators::WorkDecorator.decorate(work)
          end

          attr_writer :processing_action_name
          attr_accessor :work, :repository

          def default_repository
            QueryRepository.new
          end
        end
      end
    end
  end
end
