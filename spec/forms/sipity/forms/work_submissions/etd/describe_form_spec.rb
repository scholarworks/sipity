require "rails_helper"
require 'support/sipity/command_repository_interface'
require 'sipity/forms/work_submissions/etd/describe_form'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        RSpec.describe DescribeForm do
          let(:work) { Models::Work.new(id: '1234') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:keywords) { { work: work, requested_by: double, repository: repository } }
          subject { described_class.new(keywords) }

          before do
            allow(repository).to receive(:work_attribute_values_for).
              with(work: work, key: 'abstract', cardinality: 1).and_return(nil)
            allow(repository).to receive(:work_attribute_values_for).
              with(work: work, key: 'alternate_title', cardinality: 1).and_return(nil)
          end

          its(:processing_action_name) { is_expected.to eq('describe') }
          its(:policy_enforcer) { is_expected.to eq Policies::WorkPolicy }

          it { is_expected.to respond_to :work }
          it { is_expected.to respond_to :title }
          it { is_expected.to respond_to :abstract }
          it { is_expected.to respond_to :alternate_title }

          include Shoulda::Matchers::ActiveModel
          it { is_expected.to validate_presence_of(:title) }
          it { is_expected.to validate_presence_of(:abstract) }
          it { is_expected.to validate_presence_of(:work) }

          context 'validations' do
            it 'will require a requested_by' do
              expect { described_class.new(keywords.merge(requested_by: nil)) }.
                to raise_error(Exceptions::InterfaceCollaboratorExpectationError)
            end
          end

          context 'retrieving values from the repository' do
            let(:abstract) { 'Hello Dolly' }
            let(:title) { 'My Work title' }
            subject { described_class.new(keywords) }
            it 'will return the abstract of the work' do
              expect(repository).to receive(:work_attribute_values_for).
                with(work: work, key: 'alternate_title', cardinality: 1).and_return("")
              expect(repository).to receive(:work_attribute_values_for).
                with(work: work, key: 'abstract', cardinality: 1).and_return(abstract)
              expect(subject.abstract).to eq 'Hello Dolly'
              expect(subject.alternate_title).to eq ''
            end
          end

          it 'will retrieve the title from the work' do
            title = 'This is a title'
            expect(work).to receive(:title).and_return(title)
            subject = described_class.new(keywords)
            expect(subject.title).to eq title
          end

          context '#submit' do
            context 'with invalid data' do
              before do
                expect(subject).to receive(:valid?).and_return(false)
              end
              it 'will return false if not valid' do
                expect(subject.submit)
              end
              it 'will not create create any additional attributes entries' do
                expect { subject.submit }.
                  to_not change { Models::AdditionalAttribute.count }
              end
            end

            context 'with valid data' do
              subject { described_class.new(keywords.merge(attributes: { abstract: 'Hello Dolly', repository: repository })) }
              before do
                allow(subject).to receive(:valid?).and_return(true)
                allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
              end

              it 'will update title of the work' do
                expect(repository).to receive(:update_work_title!).exactly(1).and_call_original
                subject.submit
              end

              it 'will add additional attributes entries' do
                expect(repository).to receive(:update_work_attribute_values!).exactly(2).and_call_original
                subject.submit
              end
            end
          end
        end
      end
    end
  end
end
