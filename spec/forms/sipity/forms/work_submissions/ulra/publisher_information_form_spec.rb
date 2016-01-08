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
                submitted_for_publication: true, submission_accepted_for_publication: true
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
          it { should respond_to :submission_accepted_for_publication }
          it { should_not be_persisted }

          include Shoulda::Matchers::ActiveModel
          it { should validate_presence_of :publication_name }
          it do
            should validate_inclusion_of(
              :submission_accepted_for_publication
            ).in_array(subject.possible_submission_accepted_for_publication)
          end

          context '#submission_accepted_for_publication?' do
            [
              [nil, false],
              ['Yes', true],
              ['Pending', true],
              ['No', false]
            ].each do |value, answer|
              it "is #{answer.inspect} when submission_accepted_for_publication is #{value.inspect}" do
                subject = described_class.new(keywords.merge(attributes: { submission_accepted_for_publication: value }))
                expect(subject.submission_accepted_for_publication?).to eq(answer)
              end
            end
          end

          context '#publication_name' do
            before do
              allow(repository).to receive(:work_attribute_values_for).with(
                work: work, key: 'publication_name', cardinality: :many
              )
              allow(repository).to receive(:work_attribute_values_for).with(
                work: work, key: 'submission_accepted_for_publication', cardinality: 1
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

          context '#submission_accepted_for_publication' do
            before do
              allow(repository).to receive(:work_attribute_values_for)
            end
            it 'will be the input via the #form' do
              subject = described_class.new(keywords.merge(attributes: { submission_accepted_for_publication: 'Pending' }))
              expect(subject.submission_accepted_for_publication).to eq('Pending')
            end
            it 'will fall back on #submission_accepted_for_publication information associated with the work' do
              expect(repository).to receive(
                :work_attribute_values_for
              ).with(work: work, key: 'submission_accepted_for_publication', cardinality: 1).and_return('Yes')
              subject = described_class.new(requested_by: user, work: work, repository: repository)
              expect(subject.submission_accepted_for_publication).to eq('Yes')
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
                described_class.new(keywords.merge(attributes: { publication_name: 'bogus', submission_accepted_for_publication: true }))
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
                ).with(work: work, key: 'submission_accepted_for_publication', values: true).and_call_original
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
