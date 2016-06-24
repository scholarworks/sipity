require "rails_helper"
require 'support/sipity/command_repository_interface'

module Sipity
  module Forms
    module WorkSubmissions
      module Core
        RSpec.describe DestroyForm do
          let(:keywords) { { work: work, repository: repository, attributes: attributes, requested_by: user } }
          let(:user) { double('User') }
          let(:work) { double('Work', to_submission_window: submission_window) }
          let(:submission_window) { double('Submission Window') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:attributes) { {} }
          subject { described_class.new(keywords) }

          context 'validations' do
            it 'will be invalid without confirm_destroy' do
              subject.valid?
              expect(subject.errors[:confirm_destroy]).to be_present
            end

            it 'will be invalid if you said "no"' do
              subject = described_class.new(keywords.merge(attributes: { confirm_destroy: false }))
              subject.valid?
              expect(subject.errors[:confirm_destroy]).to be_present
            end

            it 'will be valid if you say yes' do
              subject = described_class.new(keywords.merge(attributes: { confirm_destroy: true }))
              expect(subject.valid?).to eq(true)
            end
          end

          context '#submit' do
            context 'when invalid' do
              before { allow(subject).to receive(:valid?).and_return(false) }
              it 'will return false' do
                expect(subject.submit).to be_falsey
              end
              it 'will not destroy the work' do
                expect(repository).to_not receive(:destroy_a_work)
                subject.submit
              end
            end

            context 'when valid' do
              before { allow(subject).to receive(:valid?).and_return(true) }
              it 'will destroy the object' do
                expect(repository).to receive(:destroy_a_work).with(work: work).and_call_original
                subject.submit
              end
              it 'will return the associated submission window' do
                expect(subject.submit).to eq(submission_window)
              end
            end
          end
        end
      end
    end
  end
end
