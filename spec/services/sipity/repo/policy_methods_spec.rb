require 'spec_helper'

module Sipity
  module Repo
    RSpec.describe PolicyMethods do
      let!(:repository_class) do
        class TestRepository
          include PolicyMethods
        end
      end
      subject { repository_class.new }
      after { Sipity::Repo.send(:remove_const, :TestRepository) }
      let(:subject_model) { Models::Header.new(id: '2') }
      let(:current_user) { User.new(id: '1') }
      let(:runner) { double('Runner', current_user: current_user) }

      context '.policy_unauthorized_for?' do
        # TODO: The handoff to the policy class is unpleasant. But appears to
        #   work
        it 'works for a Header and a New/Create runner' do
          allow(subject_model).to receive(:persisted?).and_return(true)
          expect(runner).to receive(:policy_authorization_method_name).and_return(:create?)
          expect(subject.policy_unauthorized_for?(runner: runner, subject: subject_model)).to eq(true)
        end
      end

      context '.find_policy_class_for' do
        context 'with a #policy_class defined on the model' do
          let(:subject_model) { double(policy_class: :my_builder) }
          it 'will use the response of the #policy_class' do
            expect(subject.find_policy_class_for(subject_model)).to eq(:my_builder)
          end
        end

        context 'without a #policy_class defined on the model' do
          it 'will interpolate what the policy should be' do
            expect(subject.find_policy_class_for(subject_model)).to eq(Policies::HeaderPolicy)
          end
        end
      end
    end
  end
end
