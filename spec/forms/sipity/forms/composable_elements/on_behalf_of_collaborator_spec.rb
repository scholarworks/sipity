require 'spec_helper'

module Sipity
  module Forms
    module ComposableElements
      RSpec.describe OnBehalfOfCollaborator do
        let(:form) { double(to_processing_action: 'an action', entity: 'a work', on_behalf_of_collaborator_id: 'an_id') }
        let(:repository) { QueryRepositoryInterface.new }
        let(:someone) { double(id: 'one') }
        let(:sometwo) { double(id: 'two') }
        let(:somethree) { double(id: 'three') }

        subject { described_class.new(form: form, repository: repository) }

        it { is_expected.to respond_to(:on_behalf_of_collaborator_id) }
        it { is_expected.to respond_to(:on_behalf_of_collaborator_id=) }

        it 'will forward delegate #on_behalf_of_collaborator to the underlying repository' do
          expect(repository).to receive(:collaborators_that_can_advance_the_current_state_of).and_return([someone, sometwo])
          expect(subject.on_behalf_of_collaborator).to eq(someone)
        end

        it 'will forward delegate #on_behalf_of_collaborator to the underlying repository' do
          allow(repository).to receive(:collaborators_that_can_advance_the_current_state_of).and_return([someone, sometwo])
          allow(repository).to receive(:collaborators_that_have_taken_the_action_on_the_entity).and_return([sometwo, somethree])
          expect(subject.valid_on_behalf_of_collaborator_ids).to eq([someone.id])
        end

        it 'will #valid_on_behalf_of_collaborators will be those that can act but have not' do
          expect(repository).to receive(:collaborators_that_can_advance_the_current_state_of).and_return([someone, sometwo])
          expect(repository).to receive(:collaborators_that_have_taken_the_action_on_the_entity).and_return([sometwo, somethree])
          expect(subject.valid_on_behalf_of_collaborators).to eq([someone])
        end
      end
    end
  end
end
