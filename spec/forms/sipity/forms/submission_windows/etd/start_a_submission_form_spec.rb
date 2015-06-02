require 'spec_helper'

module Sipity
  module Forms
    module SubmissionWindows
      module Etd
        RSpec.describe StartASubmissionForm do
          let(:keywords) { { repository: repository, submission_window: submission_window, attributes: attributes } }
          let(:attributes) { {} }
          subject { described_class.new(keywords) }
          let(:repository) { CommandRepositoryInterface.new }
          let(:submission_window) do
            Models::SubmissionWindow.new(id: 1, work_area: work_area, slug: 'start')
          end
          let(:work_area) { Models::WorkArea.new(id: 2, slug: 'etd') }
          before do
            allow(repository).to receive(:find_work_area_by).with(slug: work_area.slug).and_return(work_area)
            allow(repository).to receive(:get_controlled_vocabulary_values_for_predicate_name).with(name: 'work_patent_strategy').
              and_return(['already_patented'])
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
          its(:form_path) { should be_a(String) }
          its(:persisted?) { should eq(false) }

          it 'will have a model name like Work' do
            expect(described_class.model_name).to be_a(ActiveModel::Name)
          end

          it 'will have a default #access_rights_answer' do
            expect(described_class.new(keywords).access_rights_answer).to be_present
          end

          context 'selectable answers that are an array of symbols for SimpleForm internationalization' do
            it 'will have #access_rights_answer_for_select' do
              expect(
                described_class.new(keywords).access_rights_answer_for_select.all? { |element| element.is_a?(Symbol) }
              ).to be_truthy
            end

            it 'will have #work_publication_strategies_for_select' do
              expect(subject.work_publication_strategies_for_select.all? { |strategy| strategy.is_a?(Symbol) }).to be_truthy
            end

            it 'will have #work_patent_strategies_for_select' do
              expect(subject.work_patent_strategies_for_select.all? { |strategy| strategy.is_a?(Symbol) }).to be_truthy
            end

            it 'will have #work_types_for_select' do
              expect(subject.work_types_for_select.all? { |strategy| strategy.is_a?(Symbol) }).to be_truthy
            end
          end

          context 'validations for' do
            let(:attributes) { { title: nil, access_rights_answer: nil, work_publication_strategy: nil } }
            subject { described_class.new(keywords) }
            context '#title' do
              it 'must be present' do
                subject.valid?
                expect(subject.errors[:title]).to be_present
              end
            end
            context '#submission_window' do
              it 'must be present and will throw an exception if incorrect' do
                expect { described_class.new(keywords.merge(submission_window: nil)) }.to raise_error(PowerConverter::ConversionError)
              end
            end
            context '#access_rights_answer' do
              it 'must be present' do
                subject.valid?
                expect(subject.errors[:access_rights_answer]).to be_present
              end
              it 'must be in the given list' do
                subject = described_class.new(keywords.merge(attributes: { access_rights_answer: '__not_found__' }))
                subject.valid?
                expect(subject.errors[:access_rights_answer]).to be_present
              end
            end
            context '#work_patent_strategy' do
              before do
                expect(repository).to receive(:get_controlled_vocabulary_values_for_predicate_name).with(name: 'work_patent_strategy').
                  and_return(['already_patented'])
              end
              it 'invalid if not present' do
                subject.valid?
                expect(subject.errors[:work_patent_strategy]).to be_present
              end
              it 'will be invalid be if its not within the given list' do
                subject = described_class.new(keywords.merge(attributes: { work_patent_strategy: '__not_found__' }))
                subject.valid?
                expect(subject.errors[:work_patent_strategy]).to be_present
              end
              it 'will be valid if within the given list' do
                subject = described_class.new(keywords.merge(attributes: { work_patent_strategy: 'already_patented' }))
                subject.valid?
                expect(subject.errors[:work_patent_strategy]).to_not be_present
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
                subject = described_class.new(keywords.merge(attributes: { work_publication_strategy: '__not_found__' }))
                subject.valid?
                expect(subject.errors[:work_publication_strategy]).to be_present
              end
            end
          end

          context 'Sanitizing HTML title' do
            let(:attributes) { { title: title, access_rights_answer: nil, work_publication_strategy: nil } }
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
            let(:user) { User.new(id: '123') }
            let(:attributes) { { work_patent_strategy: 'do_not_know' } }

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
                allow(repository).to receive(:create_work!).and_return(work)
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

              it 'will grant creating user permission for' do
                expect(repository).to receive(:update_work_attribute_values!).
                  with(
                    work: work, key: subject.send(:work_patent_strategy_predicate_name), values: attributes.fetch(:work_patent_strategy)
                  ).and_call_original
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
