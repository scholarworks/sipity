require 'spec_helper'
require 'support/sipity/command_repository_interface'
require 'sipity/forms/work_submissions/etd/author_form'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        RSpec.describe AuthorForm do
          let(:work) { Models::Work.new(id: '1234') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:keywords) { { work: work, requested_by: double, repository: repository } }
          subject { described_class.new(keywords) }

          before do
            allow(repository).to receive(:work_attribute_values_for).
              with(work: work, key: 'author_name', cardinality: 1).and_return(nil)
          end

          its(:processing_action_name) { is_expected.to eq('author') }
          its(:policy_enforcer) { is_expected.to eq Policies::WorkPolicy }

          it { is_expected.to respond_to :work }
          it { is_expected.to respond_to :author_name }
          it { is_expected.to respond_to :requested_by }

          include Shoulda::Matchers::ActiveModel
          it { is_expected.to validate_presence_of(:author_name) }

          context '#submit' do
            context 'with invalid data' do
              before do
                expect(subject).to receive(:valid?).and_return(false)
              end
              it 'will return false if not valid' do
                expect(subject.submit).to eq(false)
              end
            end

            context 'with valid data' do
              subject { described_class.new(keywords.merge(attributes: { author_name: 'Hello Dolly' })) }
              before do
                allow(subject).to receive(:valid?).and_return(true)
                allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
              end

              it 'will update the author of the work' do
                expect(repository).to receive(:update_work_attribute_values!).with(
                  work: work, values: 'Hello Dolly', key: 'author_name'
                )
                subject.submit
              end
            end
          end
        end
      end
    end
  end
end
