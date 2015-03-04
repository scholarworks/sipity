require 'spec_helper'

module Sipity
  module Forms
    module Etd
      RSpec.describe SignoffOnBehalfOfForm do
        let(:work) { Models::Work.new(id: '1234') }
        let(:repository) { CommandRepositoryInterface.new }
        subject { described_class.new(work: work, repository: repository) }

        its(:enrichment_type) { should eq('signoff_on_behalf_of') }
        its(:policy_enforcer) { should eq Policies::Processing::WorkProcessingPolicy }

        it { should respond_to :work }

        context 'validation' do
          it 'will require that someone be specified for approval' do
            subject.valid?
            expect(subject.errors[:on_behalf_of_collaborator]).to be_present
          end
          it 'will require that someone amongst the collaborators is specified' do
            subject = described_class.new(work: work, repository: repository, on_behalf_of_collaborator: '__no_one__')
            subject.valid?
            expect(subject.errors[:on_behalf_of_collaborator]).to be_present
          end
        end

        context 'valid submission' do
          subject { described_class.new(work: work, repository: repository, on_behalf_of_collaborator: 'someone_valid') }
          before { allow(subject).to receive(:valid?).and_return(true) }

          it 'will mark the current user as having approved on behalf of the collaborator'

          it 'will send an email to the on_behalf_of and the graduate student'
        end
      end
    end
  end
end
