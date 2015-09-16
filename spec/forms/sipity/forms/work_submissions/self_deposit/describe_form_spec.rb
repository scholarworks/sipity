require 'spec_helper'
require 'sipity/forms/work_submissions/self_deposit/describe_form'

module Sipity
  module Forms
    module WorkSubmissions
      module SelfDeposit
        RSpec.describe DescribeForm do
          let(:work) { Models::Work.new(id: '1234') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:keywords) { { work: work, requested_by: double, repository: repository } }
          subject { described_class.new(keywords) }

          before do
            allow(repository).to receive(:work_attribute_values_for).and_return([])
          end

          its(:processing_action_name) { should eq('describe') }
          its(:policy_enforcer) { should eq Policies::WorkPolicy }

          it { should respond_to :work }
          it { should respond_to :title }
          it { should respond_to :abstract }
          it { should respond_to :alternate_title }

          context 'validations' do
            it 'will require a title' do
              subject.valid?
              expect(subject.errors[:title]).to be_present
            end

            it 'will require a abstract' do
              subject.valid?
              expect(subject.errors[:abstract]).to be_present
            end

            it 'will require a work' do
              subject = described_class.new(keywords.merge(work: nil))
              subject.valid?
              expect(subject.errors[:work]).to_not be_empty
            end

            it 'will require a requested_by' do
              expect { described_class.new(keywords.merge(requested_by: nil)) }.
                to raise_error(Exceptions::InterfaceCollaboratorExpectationError)
            end
          end

          context 'retrieving values from the repository' do
            let(:abstract) { ['Hello Dolly'] }
            let(:title) { 'My Work title' }
            subject { described_class.new(keywords) }
            it 'will return the abstract of the work' do
              expect(repository).to receive(:work_attribute_values_for).
                with(work: work, key: 'alternate_title').and_return("")
              expect(repository).to receive(:work_attribute_values_for).
                with(work: work, key: 'abstract').and_return(abstract)
              expect(subject.abstract).to eq 'Hello Dolly'
              expect(subject.alternate_title).to eq ''
            end
          end

          it 'will retrieve the title from the work' do
            title = 'This is a title'
            expect(work).to receive(:title).and_return(title)
            subject = described_class.new(keywords)
            expect(subject.title).to eq title
          end

          context 'Sanitizing HTML within attributes' do
            subject do
              described_class.new(keywords.merge(attributes: { title: title, alternate_title: alternate_title, abstract: abstract }))
            end
            context 'removes script tags' do
              let(:title) { "<script>alert('Like this');</script>" }
              let(:alternate_title) { "My alternate title: <script>alert('Like this');</script>" }
              let(:abstract) do
                "JavaScript can also be included in an anchor tag
              <a href=\"javascript:alert('CLICK HIJACK');\">like so</a>"
              end
              its(:title) { should be_present }
              its(:title) { should_not have_tag('script') }
              its(:alternate_title) { should be_present }
              its(:alternate_title) { should_not have_tag('script') }
              its(:abstract) { should be_present }
              its(:abstract) { should_not have_tag("a[href]") }
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
              it 'will not create create any additional attributes entries' do
                expect { subject.submit }.
                  to_not change { Models::AdditionalAttribute.count }
              end
            end

            context 'with valid data' do
              subject { described_class.new(keywords.merge(attributes: { abstract: 'Hello Dolly', repository: repository })) }
              before do
                allow(subject).to receive(:valid?).and_return(true)
                allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
              end

              it 'will update title of the work' do
                expect(repository).to receive(:update_work_title!).exactly(1).and_call_original
                subject.submit
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
