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
          let(:keywords) { { requested_by: user, work: work, repository: repository } }
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
          it { should respond_to :allow_pre_prints }
          it { should_not be_persisted }

          its(:available_options_for_allow_pre_prints) { should be_a(Array) }

          include Shoulda::Matchers::ActiveModel
          it { should validate_presence_of :publication_name }
          it { should validate_presence_of :allow_pre_prints }
          it { should validate_inclusion_of(:allow_pre_prints).in_array(subject.available_options_for_allow_pre_prints) }

          context '#publication_name' do
            before do
              allow(repository).to receive(:work_attribute_values_for)
            end
            it 'will be the input via the #form' do
              subject = described_class.new(keywords.merge(attributes: { publication_name: 'test' }))
              expect(subject.publication_name).to eq 'test'
            end
            it 'will fall back on #publication information associated with the work' do
              expect(repository).to receive(:work_attribute_values_for).with(work: work, key: 'publication_name').and_return('hello')
              subject = described_class.new(keywords)
              expect(subject.publication_name).to eq('hello')
            end
          end

          context '#allow_pre_prints' do
            before do
              allow(repository).to receive(:work_attribute_values_for)
            end
            it 'will be the input via the #form' do
              subject = described_class.new(keywords.merge(attributes: { allow_pre_prints: 'Yes' }))
              expect(subject.allow_pre_prints).to eq 'Yes'
            end
            it 'will fall back on #allow_pre_prints information associated with the work' do
              expect(repository).to receive(:work_attribute_values_for).with(work: work, key: 'allow_pre_prints').and_return('Yes')
              subject = described_class.new(keywords)
              expect(subject.allow_pre_prints).to eq('Yes')
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
                described_class.new(keywords.merge(attributes: { publication_name: 'bogus', allow_pre_prints: 'No' }))
              end
              before do
                allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
                allow(subject).to receive(:valid?).and_return(true)
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
