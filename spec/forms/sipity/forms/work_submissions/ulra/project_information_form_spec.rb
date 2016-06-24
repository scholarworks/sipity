require "rails_helper"
require 'support/sipity/command_repository_interface'
require 'sipity/forms/work_submissions/ulra/project_information_form'

module Sipity
  module Forms
    module WorkSubmissions
      module Ulra
        RSpec.describe ProjectInformationForm do
          let(:user) { double('User') }
          let(:work) { double('Work', title: 'The work title') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:attributes) do
            { award_category: 'An Award Category', title: 'A Title', course_name: 'A Course Name', course_number: 'A Course Number' }
          end
          let(:keywords) { { requested_by: user, attributes: attributes, work: work, repository: repository } }
          subject { described_class.new(keywords) }

          its(:default_repository) { is_expected.to respond_to(:get_controlled_vocabulary_values_for_predicate_name) }

          before do
            allow(
              repository
            ).to receive(:get_controlled_vocabulary_values_for_predicate_name).with(name: 'award_category').and_return(
              [attributes.fetch(:award_category)]
            )
          end

          include Shoulda::Matchers::ActiveModel
          it { is_expected.to validate_presence_of(:title) }
          it { is_expected.to validate_inclusion_of(:award_category).in_array(subject.award_categories_for_select) }
          it { is_expected.to validate_presence_of(:course_name) }
          it { is_expected.to validate_presence_of(:course_number) }
          it { is_expected.to validate_presence_of(:requested_by) }

          context '#initialization without attributes given' do
            subject { described_class.new(requested_by: user, attributes: {}, work: work, repository: repository) }
            it 'will fetch the title from the work' do
              expect(subject.title).to eq(work.title)
            end

            it "will fetch the additional attributes from the repository" do
              ['course_name', 'course_number', 'award_category'].each do |attribute_name|
                expect(repository).to receive(:work_attribute_values_for).
                  with(work: work, key: attribute_name.to_s, cardinality: 1).and_return("a #{attribute_name}")
              end
              subject = described_class.new(requested_by: user, attributes: {}, work: work, repository: repository)
              expect(subject.course_name).to eq('a course_name')
              expect(subject.course_number).to eq('a course_number')
              expect(subject.award_category).to eq('a award_category')
            end
          end

          context '#submit' do
            context 'with invalid data' do
              before do
                expect(subject).to receive(:valid?).and_return(false)
              end
              its(:submit) { is_expected.to eq(false) }
            end
            context 'with valid data' do
              before do
                allow(subject).to receive(:valid?).and_return(true)
                allow(subject.send(:processing_action_form)).to receive(:submit).and_yield.and_return(work)
              end
              its(:submit) { is_expected.to eq(work) }

              it 'will update the title' do
                expect(repository).to receive(:update_work_title!).with(work: work, title: attributes.fetch(:title))
                subject.submit
              end

              it 'will update the additional attributes' do
                ['course_name', 'course_number', 'award_category'].each do |attribute_name|
                  expect(repository).to receive(:update_work_attribute_values!).with(
                    work: work, key: attribute_name, values: attributes.fetch(attribute_name.to_sym)
                  ).and_call_original
                end
                subject.submit
              end
            end
          end
        end
      end
    end
  end
end
