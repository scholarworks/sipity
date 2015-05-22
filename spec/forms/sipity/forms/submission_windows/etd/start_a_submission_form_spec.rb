require 'spec_helper'

module Sipity
  module Forms
    module SubmissionWindows
      module Etd
        RSpec.describe StartASubmissionForm do
          subject { described_class.new(repository: repository, submission_window: submission_window) }
          let(:repository) { CommandRepositoryInterface.new }
          let(:submission_window) do
            Models::SubmissionWindow.new(id: 1, work_area_id: work_area.id, slug: 'etd')
          end
          let(:work_area) { Models::WorkArea.new(id: 2, slug: described_class::DEFAULT_WORK_AREA_SLUG) }
          before do
            allow(repository).to receive(:find_work_area_by).
              with(slug: work_area.slug).and_return(work_area)
          end

          its(:policy_enforcer) { should eq Policies::SubmissionWindowPolicy }
          its(:base_class) { should eq Models::Work }
          its(:default_repository) { should respond_to :create_work! }
          its(:default_repository) { should respond_to :find_submission_window_by }
          its(:to_work_area) { should eq(work_area) }

          it 'will have a model name like Work' do
            expect(described_class.model_name).to be_a(ActiveModel::Name)
          end

          it 'will have a default #access_rights_answer' do
            expect(described_class.new(repository: repository, submission_window: submission_window).access_rights_answer).to be_present
          end

          context 'selectable answers that are an array of symbols for SimpleForm internationalization' do
            it 'will have #access_rights_answer_for_select' do
              expect(
                described_class.new(
                  repository: repository, submission_window: submission_window
                ).access_rights_answer_for_select.all? { |element| element.is_a?(Symbol) }
              ).to be_truthy
            end

            it 'will have #work_publication_strategies_for_select' do
              expect(subject.work_publication_strategies_for_select.all? { |strategy| strategy.is_a?(Symbol) }).to be_truthy
            end

            it 'will have #work_types_for_select' do
              expect(subject.work_types_for_select.all? { |strategy| strategy.is_a?(Symbol) }).to be_truthy
            end
          end

          context 'validations for' do
            let(:attributes) { { title: nil, access_rights_answer: nil, work_publication_strategy: nil } }
            subject { described_class.new(repository: repository, submission_window: submission_window, attributes: attributes) }
            context '#title' do
              it 'must be present' do
                subject.valid?
                expect(subject.errors[:title]).to be_present
              end
            end
            context '#submission_window' do
              it 'must be present and will throw an exception if incorrect' do
                expect { described_class.new(repository: repository, submission_window: nil, attributes: attributes) }.
                  to raise_error(PowerConverter::ConversionError)
              end
            end
            context '#access_rights_answer' do
              it 'must be present' do
                subject.valid?
                expect(subject.errors[:access_rights_answer]).to be_present
              end
              it 'must be in the given list' do
                subject = described_class.new(
                  repository: repository, submission_window: submission_window, attributes: { access_rights_answer: '__not_found__' }
                )
                subject.valid?
                expect(subject.errors[:access_rights_answer]).to be_present
              end
            end
            context '#work_type' do
              it 'must be present' do
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
            let(:attributes) { { title: title, access_rights_answer: nil, work_publication_strategy: nil } }
            subject { described_class.new(repository: repository, attributes: attributes, submission_window: submission_window) }
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
            # subject do
            #   described_class.new(
            #     attributes: {
            #       title: 'This is my title',
            #       work_publication_strategy: 'do_not_know',
            #       access_rights_answer: Models::TransientAnswer::ACCESS_RIGHTS_PRIVATE
            #     },
            #     submission_window: submission_window
            #     repository: repository
            #   )
            # end
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
end
