require 'spec_helper'
require 'support/sipity/command_repository_interface'
require 'sipity/forms/submission_windows/library_project/propose_form'

module Sipity
  module Forms
    module SubmissionWindows
      module LibraryProject
        RSpec.describe ProposeForm do
          let(:keywords) { { repository: repository, submission_window: submission_window, requested_by: user, attributes: attributes } }
          let(:attributes) { {} }
          let(:user) { double('User') }
          subject { described_class.new(keywords) }
          let(:repository) { CommandRepositoryInterface.new }
          let(:submission_window) { Models::SubmissionWindow.new(id: 1, work_area: work_area, slug: 'propose') }
          let(:work_area) { Models::WorkArea.new(id: 2, slug: 'library-project') }
          before do
            allow(repository).to receive(:find_work_area_by).with(slug: work_area.slug).and_return(work_area)
          end

          it { should implement_processing_form_interface }
          its(:public_methods) { should include(:to_work_area) }

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


          context 'validations' do
            let(:attributes) { {} }
            subject { described_class.new(keywords) }
            include Shoulda::Matchers::ActiveModel
            it { should validate_presence_of(:requested_by) }
            it { should validate_presence_of(:title) }
            it 'should validate submission_window_is_open' do
              expect_any_instance_of(OpenForStartingSubmissionsValidator).to receive(:validate_each)
              subject.valid?
            end
          end

          context '#submit' do
            subject { described_class.new(keywords) }
            context 'with invalid data' do
              let(:attributes) { {} }
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
              let(:work) { Sipity::Models::Work.new(id: 1) }
              let(:attributes) { { title: 'Hello World' } }
              before do
                allow(subject).to receive(:valid?).and_return(true)
                allow(repository).to receive(:create_work!).and_return(work)
                allow(repository).to receive(:register_action_taken_on_entity)
              end

              it 'will return the work' do
                expect(repository).to receive(:create_work!).with(
                  title: attributes.fetch(:title), submission_window: submission_window,
                  work_type: Models::WorkType::LIBRARY_PROJECT_PROPOSAL
                ).and_return(work)
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

              it 'will also register the action on the work' do
                expect(repository).to receive(:register_action_taken_on_entity).with(
                  entity: work, action: subject.processing_action_name, requested_by: user
                ).and_call_original
                subject.submit
              end

              it 'will register the action on the submission window' do
                expect(repository).to receive(:register_action_taken_on_entity).
                  with(entity: submission_window, action: subject.processing_action_name, requested_by: user).
                  and_call_original
                subject.submit
              end
            end
          end
        end
      end
    end
  end
end
