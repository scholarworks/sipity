require 'spec_helper'
require 'support/sipity/command_repository_interface'
require 'sipity/forms/work_submissions/etd/defense_date_form'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        RSpec.describe DefenseDateForm do
          let(:work) { Models::Work.new(id: '1234') }
          let(:defense_date) { Time.zone.today }
          let(:repository) { CommandRepositoryInterface.new }
          let(:attributes) { {} }
          let(:user) { double }
          let(:keywords) { { work: work, repository: repository, requested_by: user, attributes: attributes } }
          subject { described_class.new(keywords) }

          its(:processing_action_name) { should eq('defense_date') }
          its(:policy_enforcer) { should eq Policies::WorkPolicy }

          it { should respond_to :work }
          it { should respond_to :defense_date }

          include Shoulda::Matchers::ActiveModel
          it { should validate_presence_of(:defense_date) }

          it 'will handle Rails defense_date that was input via Rails HTML multi-field date input' do
            form = described_class.new(
              keywords.merge(attributes: { 'defense_date(1i)' => "2014", 'defense_date(2i)' => "10", 'defense_date(3i)' => "1" })
            )
            expect(form.defense_date.month).to eq(10)
          end

          context '#defense_date' do
            context 'with data from the database' do
              subject { described_class.new(keywords) }
              it 'will return the defense_date of the work' do
                expect(repository).to receive(:work_attribute_values_for).
                  with(work: work, key: 'defense_date', cardinality: 1).and_return(defense_date)
                expect(subject.defense_date).to eq defense_date
              end
            end
            context 'when initial date is given is bogus' do
              subject { described_class.new(keywords.merge(attributes: { defense_date: '2014-02-31' })) }
              its(:defense_date) { is_expected.not_to be_present }
            end
          end

          context '#submit' do
            let(:user) { double('User') }
            context 'with invalid data' do
              before do
                expect(subject).to receive(:valid?).and_return(false)
              end
              it 'will return false if not valid' do
                expect(subject.submit)
              end
            end

            context 'with valid data' do
              subject { described_class.new(keywords.merge(attributes: { defense_date: '2014-10-02' })) }
              before do
                allow(subject).to receive(:valid?).and_return(true)
                allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
              end

              it 'will add additional attributes entries' do
                expect(repository).to receive(:update_work_attribute_values!).and_call_original
                subject.submit
              end
            end
          end
        end
      end
    end
  end
end
