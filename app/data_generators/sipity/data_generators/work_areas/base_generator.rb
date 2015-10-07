module Sipity
  module DataGenerators
    module WorkAreas
      # Responsible for generating the work types within the ETD.
      class BaseGenerator
        def self.call(**keywords)
          new(**keywords).call
        end

        def initialize(work_area:, processing_strategy:, **keywords)
          self.work_area = work_area
          self.processing_strategy = processing_strategy
          self.work_area_viewers = keywords.fetch(:work_area_viewers) { default_work_area_viewers }
          self.work_area_viewer_role = keywords.fetch(:work_area_viewer_role) { default_work_area_viewer_role }
        end

        private

        attr_accessor :processing_strategy, :work_area_viewers, :work_area_viewer_role
        attr_reader :work_area

        def work_area=(input)
          @work_area = PowerConverter.convert(input, to: :work_area)
        end

        def default_work_area_viewer_role
          Models::Role::WORK_AREA_VIEWER
        end

        def default_work_area_viewers
          Figaro.env.cogitate_identifier_id_for_all_verified_netid_users!
        end

        PERMITTED_WORK_AREA_VIEWER_ACTIONS = ['show'].freeze

        public

        def call
          PermissionGenerator.call(
            actors: work_area_viewers,
            roles: work_area_viewer_role,
            action_names: PERMITTED_WORK_AREA_VIEWER_ACTIONS,
            entity: work_area,
            strategy: processing_strategy,
            strategy_state: processing_strategy.initial_strategy_state
          )
        end
      end
    end
  end
end
