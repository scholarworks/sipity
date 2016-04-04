require 'spec_helper'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        RSpec.describe IngestWithPostponedCatalogingForm, type: :form do
          let(:work) { double(Sipity::Models::Work) }
          let(:scheduled_time) { '01-01-2010' }
          let(:repository) { CommandRepositoryInterface.new }
          let(:user) { double('User') }
          let(:keywords) { { work: work, repository: repository, requested_by: user } }
          subject { described_class.new(keywords.merge(attributes: { agree_to_signoff: true, scheduled_time: scheduled_time })) }

          context '#render' do
            it 'will render HTML safe submission terms and confirmation with scheduled_time' do
              form_object = double('Form Object')
              expect(work).to receive(:access_right_transition_date).and_return(scheduled_time)
              expect(form_object).to receive(:input).with(
                :scheduled_time, as: :date, input_html: { value: scheduled_time }
              ).and_return("<input />")
              expect(form_object).to receive(:input).with(:agree_to_signoff, hash_including(as: :boolean)).and_return("<input />")
              expect(subject.render(f: form_object)).to be_html_safe
            end

            it 'will render HTML safe submission terms and confirmation without scheduled_time' do
              form_object = double('Form Object')
              expect(work).to receive(:access_right_transition_date).and_return("")
              expect(form_object).to receive(:input).with(:scheduled_time, as: :date, input_html: { value: "" }).and_return("<input />")
              expect(form_object).to receive(:input).with(:agree_to_signoff, hash_including(as: :boolean)).and_return("<input />")
              expect(subject.render(f: form_object)).to be_html_safe
            end
          end

          its(:legend) { is_expected.to be_html_safe }
          its(:signoff_agreement) { is_expected.to be_html_safe }
          its(:template) { is_expected.to eq(Forms::STATE_ADVANCING_ACTION_CONFIRMATION_TEMPLATE_NAME) }

          include Shoulda::Matchers::ActiveModel
          it { is_expected.to validate_presence_of(:scheduled_time) }
          it { is_expected.to validate_acceptance_of(:agree_to_signoff) }

          context '#scheduled_time' do
            it 'will be set by extracting from the attributes' do
              date = Date.new(2015, 10, 5)
              expect(repository).to_not receive(:scheduled_time_from_work)
              form = described_class.new(keywords.merge(attributes: { agree_to_signoff: true, scheduled_time: date.strftime('%Y-%m-%d') }))
              expect(form.scheduled_time).to eq(date)
            end
            it 'will be set by asking the work for the previous scheduled_time if no attributes are given' do
              today = Time.zone.today
              expect(repository).to receive(:scheduled_time_from_work).and_return(today)
              form = described_class.new(keywords.merge(attributes: { agree_to_signoff: true }))
              expect(form.scheduled_time).to eq(today)
            end
            it 'will be nil if neither the attributes nor work have a given value' do
              expect(repository).to receive(:scheduled_time_from_work).and_return(nil)
              form = described_class.new(keywords.merge(attributes: { agree_to_signoff: true }))
              expect(form.scheduled_time).to be_nil
            end
          end

          context '#submit' do
            context 'with a provided scheduled_time' do
              subject { described_class.new(keywords.merge(attributes: { agree_to_signoff: true, scheduled_time: scheduled_time })) }

              before do
                allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
              end

              it 'will create administrative scheduled actions entries' do
                expect(repository).to receive(:create_scheduled_action).exactly(1).and_call_original
                subject.submit
              end
            end
          end
        end
      end
    end
  end
end
