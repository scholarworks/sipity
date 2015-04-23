require 'rails_helper'

module Sipity
  module Services
    RSpec.describe CreateWorkAreaService do

      it 'will create the WorkArea application concept if none exist' do
        work_area = described_class.call(slug: 'worm', work_area_managers: actor)
        expect(Models::ApplicationConcept.where(class_name: work_area.class).count).to eq(1)
      end

      it 'will create a Processing Strategy for the ApplicationConcept and not the WorkArea' do
        work_area = described_class.call(slug: 'worm', work_area_managers: actor)

        expect(Models::Processing::Strategy.where(proxy_for: work_area).count).to eq(0)

        application_concept = Models::ApplicationConcept.find_by!(class_name: work_area.class.to_s)

        # By convention the last one created should be for the WorkArea concept
        expect(Models::Processing::Strategy.last.proxy_for).to eq(application_concept)
      end

      it 'will create the bare-bones entries based on the slug' do
        expect do
          expect(described_class.call(slug: 'worm')).to be_a(Models::WorkArea)
        end.to change { Models::WorkArea.count }.by(1)
      end

      let(:actor) { Models::Processing::Actor.new(id: 2, proxy_for_id: 3, proxy_for_type: 'User') }
      it 'will grant permission specific permission but not general permission' do
        work_area = described_class.call(slug: 'worm', work_area_managers: actor)

        expect(
          Models::Processing::EntitySpecificResponsibility.where(
            entity: work_area.processing_entity,
            actor_id: actor.id
          ).count
        ).to eq(1)

        expect(Models::Processing::StrategyResponsibility.count).to eq(0)
      end
    end
  end
end
