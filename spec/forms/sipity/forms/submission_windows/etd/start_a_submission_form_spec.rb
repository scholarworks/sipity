require 'spec_helper'
require 'support/sipity/command_repository_interface'
require 'sipity/forms/submission_windows/etd/start_a_submission_form'

module Sipity
  module Forms
    module SubmissionWindows
      module Etd
        RSpec.describe StartASubmissionForm do
          let(:keywords) { { requested_by: user, repository: repository, submission_window: submission_window, attributes: attributes } }
          let(:attributes) { {} }
          subject { described_class.new(keywords) }
          let(:repository) { CommandRepositoryInterface.new }
          let(:user) { User.new(id: '123') }
          let(:submission_window) do
            Models::SubmissionWindow.new(id: 1, work_area: work_area, slug: 'start')
          end
          let(:work_area) { Models::WorkArea.new(id: 2, slug: 'etd') }
          before do
            allow(repository).to receive(:find_work_area_by).with(slug: work_area.slug).and_return(work_area)
            allow_any_instance_of(described_class).to receive(:possible_work_publication_strategies).and_return(['already_published'])
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
          its(:possible_access_right_codes) { should be_a(Array) }
          its(:access_rights_answer_for_select) { should be_a(Array) }

          it 'will have a model name like Work' do
            expect(described_class.model_name).to be_a(ActiveModel::Name)
          end

          it 'will have a default #access_rights_answer' do
            expect(described_class.new(keywords).access_rights_answer).to be_present
          end

          it { should delegate_method(:work_publication_strategy).to(:publication_and_patenting_intent_extension) }
          it { should delegate_method(:work_publication_strategies_for_select).to(:publication_and_patenting_intent_extension) }

          context 'selectable answers that are an array of symbols for SimpleForm internationalization' do
            it 'will have #access_rights_answer_for_select' do
              expect(
                described_class.new(keywords).access_rights_answer_for_select.all? { |element| element.is_a?(Symbol) }
              ).to be_truthy
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
            let(:attributes) { { work_publication_strategy: 'do_not_know' } }

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
                allow(repository).to receive(:create_work!).and_return(work)
                allow(repository).to receive(:register_action_taken_on_entity)
              end
              it 'will assign the work attribute on submit' do
                expect { subject.submit }.to change(subject, :work).from(nil).to(work)
              end
              it 'will return the work having created the work, added the attributes,
              assigned collaborators, assigned permission, and loggged the event' do
                expect(repository).to receive(:create_work!).and_return(work)
                response = subject.submit
                expect(response).to eq(work)
              end

              it 'will register the action on the submission window' do
                expect(repository).to receive(:register_action_taken_on_entity).
                  with(entity: submission_window, action: subject.processing_action_name, requested_by: user).
                  and_call_original
                subject.submit
              end

              it 'will also register the action on the work' do
                expect(repository).to receive(:register_action_taken_on_entity).with(
                  entity: work, action: subject.processing_action_name, requested_by: user
                ).and_call_original
                subject.submit
              end

              it 'will grant creating user permission for' do
                expect(repository).to receive(:grant_creating_user_permission_for!).and_call_original
                subject.submit
              end

              it 'will persist the work patent strategy' do
                expect_any_instance_of(subject.send(:publication_and_patenting_intent_extension_builder)).
                  to_not receive(:persist_work_patent_strategy)
                subject.submit
              end

              it 'will persist the work work_publication_strategy strategy' do
                expect(subject).to receive(:persist_work_publication_strategy).and_call_original
                subject.submit
              end
            end
          end
        end
      end
    end
  end
end
