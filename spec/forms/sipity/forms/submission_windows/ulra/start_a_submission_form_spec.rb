require 'spec_helper'
require 'sipity/forms/submission_windows/ulra/start_a_submission_form'

module Sipity
  module Forms
    module SubmissionWindows
      module Ulra
        RSpec.describe StartASubmissionForm do
          let(:keywords) { { repository: repository, submission_window: submission_window, requested_by: user, attributes: attributes } }
          let(:attributes) { {} }
          let(:user) { double('User') }
          subject { described_class.new(keywords) }
          let(:repository) { CommandRepositoryInterface.new }
          let(:submission_window) { Models::SubmissionWindow.new(id: 1, work_area: work_area, slug: '1234') }
          let(:work_area) { Models::WorkArea.new(id: 2, slug: described_class::DEFAULT_WORK_AREA_SLUG) }
          before do
            allow(repository).to receive(:find_work_area_by).with(slug: work_area.slug).and_return(work_area)
            allow(repository).to receive(:get_controlled_vocabulary_values_for_predicate_name).with(name: 'award_category').and_return([])
            allow(repository).to receive(:get_controlled_vocabulary_values_for_predicate_name).with(name: 'work_publication_strategy').
              and_return(['valid_work_publication_strategy'])
          end

          it { should implement_processing_form_interface }

          context 'its class configuration' do
            subject { described_class }
            its(:base_class) { should eq(Models::Work) }
            its(:model_name) { should eq(Models::Work.model_name) }
            it 'will delegate human_attribute_name to the base class' do
              expect(Models::Work).to receive(:human_attribute_name).and_call_original
              expect(subject.human_attribute_name(:title)).to be_a(String)
            end
          end

          its(:policy_enforcer) { should eq Policies::SubmissionWindowPolicy }
          its(:base_class) { should eq Models::Work }
          its(:default_repository) { should respond_to :create_work! }
          its(:default_repository) { should respond_to :find_submission_window_by }
          its(:processing_subject_name) { should eq :submission_window }
          its(:entity) { should eq submission_window }
          its(:to_work_area) { should eq(work_area) }
          its(:persisted?) { should eq(false) }

          it 'will delegate #to_processing_entity to the submission window' do
            expect(submission_window).to receive(:to_processing_entity)
            subject.to_processing_entity
          end

          it 'will have a model name like Work' do
            expect(described_class.model_name).to be_a(ActiveModel::Name)
          end

          it 'will have #award_categories_for_select' do
            expect(repository).to receive(:get_controlled_vocabulary_values_for_predicate_name).with(name: 'award_category').
              and_return(['award_category', 'bogus'])
            expect(subject.award_categories_for_select).to be_a(Array)
          end

          context 'selectable answers that are an array of symbols for SimpleForm internationalization' do
            it 'will have #work_publication_strategies_for_select' do
              expect(subject.work_publication_strategies_for_select.all? { |strategy| strategy.is_a?(Symbol) }).to be_truthy
            end
          end

          context 'validations for' do
            let(:attributes) { { title: nil, work_publication_strategy: nil, advisor_net_id: nil, award_category: nil } }
            subject { described_class.new(keywords) }
            context '#title' do
              it 'must be present' do
                subject.valid?
                expect(subject.errors[:title]).to be_present
              end
            end
            context '#advisor_netid' do
              it 'must be present' do
                subject.valid?
                expect(subject.errors[:advisor_netid]).to be_present
              end
            end
            context '#award_category' do
              it 'must be present' do
                subject.valid?
                expect(subject.errors[:award_category]).to be_present
              end
            end
            context '#submission_window' do
              it 'must be present and will throw an exception if incorrect' do
                expect { described_class.new(requested_by: user, repository: repository, attributes: attributes) }.
                  to raise_error(ArgumentError)
              end
            end
            context '#work_type' do
              it 'must be present' do
                subject = described_class.new(keywords.merge(attributes: { work_type: nil }))
                subject.valid?
                expect(subject.errors[:work_type]).to be_present
              end
            end
            context '#work_publication_strategy' do
              it 'must be present' do
                subject.valid?
                expect(subject.errors[:work_publication_strategy]).to be_present
              end
              it 'must be from the approved list' do
                subject = described_class.new(keywords.merge(attributes: { work_publication_strategy: '__not_found__' }))
                subject.valid?
                expect(subject.errors[:work_publication_strategy]).to be_present
              end
              it 'will be valid if from approved list' do
                subject = described_class.new(keywords.merge(attributes: { work_publication_strategy: 'valid_work_publication_strategy' }))
                subject.valid?
                expect(subject.errors[:work_publication_strategy]).to_not be_present
              end
            end
          end

          context 'Sanitizing HTML title' do
            let(:attributes) { { title: title, work_publication_strategy: nil, advisor_net_id: nil, award_category: nil } }
            subject { described_class.new(keywords) }
            context 'removes script tags' do
              let(:title) { "<script>alert('Like this');</script>" }
              it { expect(subject.title).to_not have_tag('script') }
            end
            context 'removes JavaScript links' do
              let(:title) do
                "JavaScript can also be included in an anchor tag
            <a href=\"javascript:alert('CLICK HIJACK');\">like so</a>"
              end
              it { expect(subject.title).to_not have_tag("a[href]") }
            end
          end

          context '#submit' do
            let(:attributes) do
              {
                title: "This is my title",
                work_publication_strategy: 'do_not_know',
                advisor_net_id: 'dummy_id',
                award_category: 'some_category'
              }
            end
            subject { described_class.new(keywords) }
            context 'with invalid data' do
              it 'will not create a a work' do
                allow(subject).to receive(:valid?).and_return(false)
                expect { subject.submit }.
                  to_not change { Models::Work.count }
              end
              it 'will return false' do
                allow(subject).to receive(:valid?).and_return(false)
                expect(subject.submit).to eq(false)
              end
            end
            context 'with valid data' do
              let(:user) { User.new(id: '123') }
              let(:work) { double }
              before do
                expect(subject).to receive(:valid?).and_return(true)
              end
              it 'will return the work having created the work, added the attributes,
              assigned collaborators, assigned permission, and loggged the event' do
                expect(repository).to receive(:create_work!).and_return(work)
                response = subject.submit
                expect(response).to eq(work)
              end

              it 'will log the event' do
                expect(repository).to receive(:log_event!).and_call_original
                subject.submit
              end

              it 'will grant creating user permission for' do
                expect(repository).to receive(:grant_creating_user_permission_for!).and_call_original
                subject.submit
              end
            end
          end
        end
      end
    end
  end
end
