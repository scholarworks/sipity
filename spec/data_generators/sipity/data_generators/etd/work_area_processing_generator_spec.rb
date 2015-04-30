require 'rails_helper'

module Sipity
  module DataGenerators
    module Etd
      # Responsible for generating the submission window for the ETD work area.
      RSpec.describe WorkAreaProcessingGenerator do
        let(:work_area) { Models::WorkArea.new(id: 1, slug: 'etd') }
        let(:processing_strategy) { Models::Processing::Strategy.create!(id: 2, name: 'etd processing') }
        subject { described_class }

        before do
          Models::Processing::Entity.create!(
            proxy_for_id: work_area.id,
            proxy_for_type: work_area.class,
            strategy: processing_strategy,
            strategy_state: processing_strategy.initial_strategy_state
          )
        end

        it 'will grant permission to show the work area if a work_area_manager is given' do
          user = Factories.create_user

          described_class.call(work_area: work_area, processing_strategy: processing_strategy, work_area_viewers: user)

          described_class::PERMITTED_WORK_AREA_VIEWER_ACTIONS.each do |action_name|
            permission_to_work_area_action = Policies::Processing::ProcessingEntityPolicy.call(
              user: user, entity: work_area, action_to_authorize: action_name
            )
            expect(permission_to_work_area_action).to be_truthy
          end
        end

        context 'default values' do
          subject { described_class.new(work_area: work_area, processing_strategy: processing_strategy) }
          its(:default_work_area_viewers) { should eq Models::Group.all_registered_users }
          its(:default_work_area_viewer_role) { should eq Models::Role::WORK_AREA_VIEWER }
        end

      end
    end
  end
end
