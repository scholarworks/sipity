require 'rails_helper'

module Sipity
  module Services
    RSpec.describe CreateWorkAreaService do
      let(:user) { Sipity::Factories.create_user }

      it 'will create the WorkArea application concept if none exist' do
        work_area = described_class.call(slug: 'worm', work_area_managers: user)
        expect(Models::ApplicationConcept.where(class_name: work_area.class).count).to eq(1)
      end

      it 'will create a Processing Strategy for the ApplicationConcept and not the WorkArea' do
        work_area = described_class.call(slug: 'worm', work_area_managers: user)

        expect(Models::Processing::Strategy.where(proxy_for: work_area).count).to eq(0)

        application_concept = Models::ApplicationConcept.find_by!(class_name: work_area.class.to_s)

        # By convention the last one created should be for the WorkArea concept
        expect(Models::Processing::Strategy.last.proxy_for).to eq(application_concept)
      end

      it 'will grant permission specific permission but not general permission' do
        work_area = described_class.call(slug: 'worm', work_area_managers: user)

        expect(
          Models::Processing::EntitySpecificResponsibility.where(
            entity: work_area.processing_entity,
            actor: Conversions::ConvertToProcessingActor.call(user)
          ).count
        ).to eq(1)

        expect(Models::Processing::StrategyResponsibility.count).to eq(0)
      end

      it 'will grant permission to show the work area if a work_area_manager is given' do
        another_work_area = described_class.call(slug: 'another')
        work_area = described_class.call(slug: 'worm', work_area_managers: user)

        permission_to_show_work_area = Policies::Processing::ProcessingEntityPolicy.call(
          user: user, entity: work_area, action_to_authorize: 'show'
        )
        expect(permission_to_show_work_area).to be_truthy

        permission_to_show_another_work_area = Policies::Processing::ProcessingEntityPolicy.call(
          user: user, entity: another_work_area, action_to_authorize: 'show'
        )
        expect(permission_to_show_another_work_area).to be_falsey
      end
    end
  end
end
