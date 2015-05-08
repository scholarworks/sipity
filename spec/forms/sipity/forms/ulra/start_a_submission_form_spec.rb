require 'spec_helper'

module Sipity
  module Forms
    module Ulra
      RSpec.describe StartASubmissionForm do
        subject { described_class.new(repository: repository, submission_window: submission_window) }
        let(:repository) { CommandRepositoryInterface.new }
        let(:submission_window) { Models::SubmissionWindow.new(id: 1, work_area_id: work_area.id, slug: '1234') }
        let(:work_area) { Models::WorkArea.new(id: 2, slug: described_class::DEFAULT_WORK_AREA_SLUG) }
        before do
          allow(repository).to receive(:find_work_area_by).with(slug: work_area.slug).and_return(work_area)
          allow(repository).to receive(:get_controlled_vocabulary_values_for_predicate_name).with(name: 'award_category').and_return([])
        end

        its(:default_repository) { should respond_to :create_work! }
        its(:default_repository) { should respond_to :find_submission_window_by }
        its(:policy_enforcer) { should eq(Policies::SubmissionWindowPolicy) }
        its(:default_work_type) { should eq(Models::WorkType::ULRA_SUBMISSION) }

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
          subject { described_class.new(repository: repository, submission_window: submission_window, attributes: attributes) }
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
              expect { described_class.new(repository: repository, attributes: attributes) }.to raise_error(ArgumentError)
            end
          end
          context '#work_type' do
            it 'must be present' do
              subject = described_class.new(submission_window: submission_window, repository: repository, attributes: { work_type: nil })
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
              subject = described_class.new(
                repository: repository, submission_window: submission_window, attributes: { work_publication_strategy: '__not_found__' }
              )
              subject.valid?
              expect(subject.errors[:work_publication_strategy]).to be_present
            end
          end
        end

        context 'Sanitizing HTML title' do
          let(:attributes) { { title: title, work_publication_strategy: nil, advisor_net_id: nil, award_category: nil } }
          subject { described_class.new(repository: repository, submission_window: submission_window, attributes: attributes) }
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
          let(:user) { User.new(id: '123') }
          subject do
            described_class.new(
              repository: repository,
              submission_window: submission_window,
              attributes: {
                title: 'This is my title',
                work_publication_strategy: 'do_not_know',
                advisor_net_id: 'dummy_id',
                award_category: 'some_category'
              }
            )
          end
          context 'with invalid data' do
            it 'will not create a a work' do
              allow(subject).to receive(:valid?).and_return(false)
              expect { subject.submit(requested_by: user) }.
                to_not change { Models::Work.count }
            end
            it 'will return false' do
              allow(subject).to receive(:valid?).and_return(false)
              expect(subject.submit(requested_by: user)).to eq(false)
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
              response = subject.submit(requested_by: user)
              expect(response).to eq(work)
            end

            it 'will log the event' do
              expect(repository).to receive(:log_event!).and_call_original
              subject.submit(requested_by: user)
            end

            it 'will grant creating user permission for' do
              expect(repository).to receive(:grant_creating_user_permission_for!).and_call_original
              subject.submit(requested_by: user)
            end

            it 'will send emails to the creating user' do
              expect(repository).to receive(:create_work!).and_return(work)
              expect(repository).to receive(:send_notification_for_entity_trigger).
                with(notification: 'confirmation_of_work_created', entity: work, acting_as: 'creating_user').
                and_call_original
              subject.submit(requested_by: user)
            end
          end
        end
      end
    end
  end
end
