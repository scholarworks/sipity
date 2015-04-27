require 'rails_helper'

module Sipity
  module Services
    RSpec.describe CreateWorkAreaService do
      let(:user) { Sipity::Factories.create_user }

      it 'will create a processing strategy if none exists for work areas otherwise reuse it' do
        expect { described_class.call(name: 'Worm', slug: 'worm') }.
          to change { Models::Processing::Strategy.count }.by(1)

        expect { described_class.call(name: 'Another', slug: 'another') }.
          to_not change { Models::Processing::Strategy.count }
      end

      it 'will create a strategy usages for each work areas' do
        expect do
          described_class.call(name: 'Worm', slug: 'worm')
          described_class.call(name: 'Another', slug: 'another')
        end.to change { Models::Processing::StrategyUsage.count }.by(2)
      end

      it 'will grant permission specific permission but not general permission' do
        work_area = described_class.call(name: 'Worm', slug: 'worm', work_area_managers: user)

        expect(
          Models::Processing::EntitySpecificResponsibility.where(
            entity: work_area.processing_entity,
            actor: Conversions::ConvertToProcessingActor.call(user)
          ).count
        ).to eq(1)

        expect(Models::Processing::StrategyResponsibility.count).to eq(0)
      end

      it 'will grant permission to show the work area if a work_area_manager is given' do
        another_work_area = described_class.call(name: 'Another', slug: 'another')
        work_area = described_class.call(name: 'Worm', slug: 'worm', work_area_managers: user)

        permission_to_show_work_area = Policies::Processing::ProcessingEntityPolicy.call(
          user: user, entity: work_area, action_to_authorize: 'show'
        )
        expect(permission_to_show_work_area).to be_truthy

        permission_to_show_another_work_area = Policies::Processing::ProcessingEntityPolicy.call(
          user: user, entity: another_work_area, action_to_authorize: 'show'
        )
        expect(permission_to_show_another_work_area).to be_falsey
      end

      it 'will grant permission to create a submission window (via the submission window form)' do
        work_area = described_class.call(name: 'Worm', slug: 'worm', work_area_managers: user)

        permission_to_create_a_submission_window = Policies::Processing::ProcessingEntityPolicy.call(
          user: user, entity: work_area, action_to_authorize: 'create_submission_window'
        )
        expect(permission_to_create_a_submission_window).to be_truthy
      end
    end
  end
end
