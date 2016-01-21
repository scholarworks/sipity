require 'spec_helper'
require 'support/sipity/command_repository_interface'
require 'sipity/forms/work_submissions/ulra/publisher_information_form'

module Sipity
  module Forms
    module WorkSubmissions
      module Ulra
        RSpec.describe PublisherInformationForm do
          let(:work) { double('Work') }
          let(:user) { double('User') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:keywords) do
            {
              requested_by: user, work: work, repository: repository,
              attributes: {
                submitted_for_publication: true, publication_status_of_submission: true
              }
            }
          end
          subject { described_class.new(keywords) }

          its(:processing_action_name) { should eq('publisher_information') }
          its(:policy_enforcer) { should eq Policies::WorkPolicy }
          its(:base_class) { should eq(Models::Work) }

          context 'class configuration' do
            subject { described_class }
            it { should delegate_method(:model_name).to(:base_class) }
            it { should delegate_method(:human_attribute_name).to(:base_class) }
          end

          it { should respond_to :work }
          it { should respond_to :entity }
          it { should respond_to :publication_name }
          it { should respond_to :publication_status_of_submission }
          it { should_not be_persisted }

          include Shoulda::Matchers::ActiveModel
          it { should validate_presence_of :publication_name }
          it do
            should validate_inclusion_of(
              :publication_status_of_submission
            ).in_array(subject.possible_publication_status_of_submission)
          end

          context '#publication_name_required?' do
            [
              [nil, false],
              ['Accepted', true],
              ['Under Review', true],
              ['Not Accepted', false]
            ].each do |value, answer|
              it "is #{answer.inspect} when publication_status_of_submission is #{value.inspect}" do
                subject = described_class.new(keywords.merge(attributes: { publication_status_of_submission: value }))
                expect(subject.publication_name_required?).to eq(answer)
              end
            end
          end

          context '#publication_name' do
            before do
              allow(repository).to receive(:work_attribute_values_for).with(
                work: work, key: 'publication_name', cardinality: :many
              )
              allow(repository).to receive(:work_attribute_values_for).with(
                work: work, key: 'publication_status_of_submission', cardinality: 1
              )
              allow(repository).to receive(:work_attribute_values_for).with(
                work: work, key: 'submitted_for_publication', cardinality: 1
              )
            end
            it 'will be the input via the #form' do
              subject = described_class.new(keywords.merge(attributes: { publication_name: 'test' }))
              expect(subject.publication_name).to eq 'test'
            end
            it 'will fall back on #publication information associated with the work' do
              expect(repository).to receive(
                :work_attribute_values_for
              ).with(work: work, key: 'publication_name', cardinality: :many).and_return('hello')
              subject = described_class.new(requested_by: user, work: work, repository: repository)
              expect(subject.publication_name).to eq(['hello'])
            end
          end

          context '#publication_status_of_submission' do
            before do
              allow(repository).to receive(:work_attribute_values_for)
            end
            it 'will be the input via the #form' do
              subject = described_class.new(keywords.merge(attributes: { publication_status_of_submission: 'Pending' }))
              expect(subject.publication_status_of_submission).to eq('Pending')
            end
            it 'will fall back on #publication_status_of_submission information associated with the work' do
              expect(repository).to receive(
                :work_attribute_values_for
              ).with(work: work, key: 'publication_status_of_submission', cardinality: 1).and_return('Yes')
              subject = described_class.new(requested_by: user, work: work, repository: repository)
              expect(subject.publication_status_of_submission).to eq('Yes')
            end
          end

          context '#submit' do
            context 'with invalid data' do
              before do
                expect(subject).to receive(:valid?).and_return(false)
              end
              it 'will return false if not valid' do
                expect(subject.submit)
              end
            end

            context 'with valid data' do
              subject do
                described_class.new(keywords.merge(attributes: { publication_name: 'bogus', publication_status_of_submission: true }))
              end
              before do
                allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
                allow(subject).to receive(:valid?).and_return(true)
              end

              it 'will add additional attributes entries' do
                expect(repository).to receive(
                  :update_work_attribute_values!
                ).with(work: work, key: 'publication_name', values: 'bogus').and_call_original
                expect(repository).to receive(
                  :update_work_attribute_values!
                ).with(work: work, key: 'publication_status_of_submission', values: true).and_call_original
                expect(repository).to receive(
                  :update_work_attribute_values!
                ).with(work: work, key: 'submitted_for_publication', values: false).and_call_original
                subject.submit
              end
            end
          end
        end
      end
    end
  end
end
