module Sipity
  module Forms
    module WorkSubmissions
      module Core
        RSpec.describe DestroyForm do
          let(:keywords) { { work: work, repository: repository, attributes: attributes } }
          let(:user) { double('User') }
          let(:work) { double('Work', to_submission_window: submission_window) }
          let(:submission_window) { double('Submission Window') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:attributes) { {} }
          subject { described_class.new(keywords) }

          context 'validations' do
            it 'will be invalid without confirm destroy' do
              subject.valid?
              expect(subject.errors[:confirm destroy]).to be_present
            end

            it 'will be invalid if you said "no"' do
              subject = described_class.new(keywords.merge(attributes: { confirm destroy: false }))
              subject.valid?
              expect(subject.errors[:confirm destroy]).to be_present
            end

            it 'will be valid if you say yes' do
              subject = described_class.new(keywords.merge(attributes: { confirm destroy: true }))
              expect(subject.valid?).to eq(true)
            end
          end

          context '#submit' do
            context 'when invalid' do
              before { allow(subject).to receive(:valid?).and_return(false) }
              it 'will return false' do
                expect(subject.submit(requested_by: user)).to be_falsey
              end
              it 'will not destroy the work' do
                expect(repository).to_not receive(:destroy_a_work)
                subject.submit(requested_by: user)
              end
            end

            context 'when valid' do
              before { allow(subject).to receive(:valid?).and_return(true) }
              it 'will destroy the object' do
                expect(repository).to receive(:destroy_a_work).with(work: work).and_call_original
                subject.submit(requested_by: user)
              end
              it 'will return the associated submission window' do
                expect(subject.submit(requested_by: user)).to eq(submission_window)
              end
            end
          end
        end
      end
    end
  end
end
