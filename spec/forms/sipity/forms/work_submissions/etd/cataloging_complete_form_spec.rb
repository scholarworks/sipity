require 'spec_helper'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        RSpec.describe CatalogingCompleteForm do
          let(:work) { Models::Work.new(id: '1234', title: 'Title 1') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:user) { double('User') }
          let(:keywords) { { work: work, repository: repository, requested_by: user, attributes: {} } }
          let(:oclc_number) { "123456789" }
          let(:catalog_system_number) { "abc" }
          subject do
            described_class.new(
              keywords.merge(
                attributes: { agree_to_signoff: true, oclc_number: oclc_number, catalog_system_number: catalog_system_number }
              )
            )
          end

          include Shoulda::Matchers::ActiveModel
          it { should validate_presence_of(:oclc_number) }
          it { should validate_presence_of(:catalog_system_number) }
          it { should validate_acceptance_of(:agree_to_signoff) }

          context '#render' do
            it 'will render HTML safe submission terms and confirmation' do
              form_object = double('Form Object')
              expect(form_object).to receive(:input).with(:oclc_number, input_html: { required: "required" }).and_return("<input />")
              expect(form_object).to receive(:input).with(
                :catalog_system_number, input_html: { required: "required" }, label: 'ALEPH system number'
              ).and_return("<input />")
              expect(form_object).to receive(:input).with(:agree_to_signoff, hash_including(as: :boolean)).and_return("<input />")
              expect(subject.render(f: form_object)).to be_html_safe
            end
          end

          its(:legend) { should be_html_safe }
          its(:signoff_agreement) { should be_html_safe }
          its(:template) { should eq(Forms::STATE_ADVANCING_ACTION_CONFIRMATION_TEMPLATE_NAME) }

          context 'with data from the repository' do
            subject { described_class.new(keywords) }
            before { allow(repository).to receive(:work_attribute_values_for).and_call_original }
            its(:oclc_number) do
              expect(repository).to receive(:work_attribute_values_for).
                with(work: work, key: 'oclc_number', cardinality: 1).and_return(123)
              should eq(123)
            end
            its(:catalog_system_number) do
              expect(repository).to receive(:work_attribute_values_for).
                with(work: work, key: 'catalog_system_number', cardinality: 1).and_return('abc')
              should eq('abc')
            end
          end

          context "submit" do
            before do
              allow(subject).to receive(:valid?).and_return(true)
              allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
            end

            it 'will add additional attributes entries' do
              expect(repository).to receive(:update_work_attribute_values!).with(
                work: work, key: 'catalog_system_number', values: catalog_system_number
              )
              expect(repository).to receive(:update_work_attribute_values!).with(work: work, key: 'oclc_number', values: oclc_number)
              subject.submit
            end
          end
        end
      end
    end
  end
end
