require 'rails_helper'
require 'sipity/data_generators/find_or_create_work_area'

module Sipity
  module DataGenerators
    RSpec.describe FindOrCreateWorkArea do
      let(:cogitate_data) { JSON.parse(Rails.root.join('spec/fixtures/cogitate/authenticated_agent.json').read) }
      let(:user) { Models::AuthenticationAgent.new_from_cogitate_data(data: cogitate_data) }
      before do
        allow(WorkAreas::EtdGenerator).to receive(:call)
      end
      it 'will create a processing strategy if none exists for work areas otherwise reuse it' do
        expect { described_class.call(name: 'Worm', slug: 'worm') }.
          to change { Models::Processing::Strategy.count }.by(1)

        expect { described_class.call(name: 'Another', slug: 'another') }.
          to_not change { Models::Processing::Strategy.count }
      end

      it 'can be called repeatedly without updating things' do
        described_class.call(name: 'Worm', slug: 'worm')
        [:update_attribute, :update_attributes, :update_attributes!, :save, :save!, :update, :update!].each do |method_names|
          expect_any_instance_of(ActiveRecord::Base).to_not receive(method_names)
        end
        described_class.call(name: 'Worm', slug: 'worm')
      end

      it 'will call the custom work area processing generator' do
        expect(WorkAreas::EtdGenerator).to receive(:call)
        described_class.call(name: 'ETD', slug: 'etd')
      end

      it 'will create a strategy usages for each work areas (and yield)' do
        expect do
          expect { |b| described_class.call(name: 'Worm', slug: 'worm', &b) }.to yield_with_args(Models::WorkArea)
          expect { |b| described_class.call(name: 'Another', slug: 'another', &b) }.to yield_with_args(Models::WorkArea)
        end.to change { Models::Processing::StrategyUsage.count }.by(2)
      end

      it 'will grant permission to show the work area if a work_area_manager is given' do
        another_work_area = described_class.call(name: 'Another', slug: 'another')
        work_area = described_class.call(name: 'Worm', slug: 'worm', work_area_managers: user)

        described_class::PERMITTED_WORK_MANAGER_ACTIONS.each do |action_name|
          permission_to_work_area_action = Policies::Processing::ProcessingEntityPolicy.call(
            user: user, entity: work_area, action_to_authorize: action_name
          )
          expect(permission_to_work_area_action).to be_truthy

          permission_to_other_work_area_action = Policies::Processing::ProcessingEntityPolicy.call(
            user: user, entity: another_work_area, action_to_authorize: 'show'
          )
          expect(permission_to_other_work_area_action).to be_falsey
        end
      end
    end
  end
end
