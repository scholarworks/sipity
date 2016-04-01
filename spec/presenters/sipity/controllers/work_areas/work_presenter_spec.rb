module Sipity
  module Controllers
    module WorkAreas
      RSpec.describe WorkPresenter do
        let(:context) { PresenterHelper::ContextWithForm.new(repository: QueryRepositoryInterface.new) }
        let(:work) do
          double('Work', title: 'hello', work_type: 'doctoral_dissertation', processing_state: 'new', created_at: Time.zone.today)
        end

        subject { described_class.new(context, work: work) }

        its(:title) { is_expected.to be_html_safe }
        its(:processing_state) { is_expected.to eq('New') }
        its(:date_created) { is_expected.to be_a(String) }
        its(:creator_names_to_sentence) { is_expected.to be_a(String) }
        its(:program_names_to_sentence) { is_expected.to be_a(String) }
        its(:work_type) { is_expected.to eq('Doctoral dissertation') }
        it { is_expected.to delegate_method(:submission_window).to(:work) }

        it 'will delegate path to PowerConverter' do
          expect(PowerConverter).to receive(:convert).with(work, to: :access_path).and_return('/the/path')
          expect(subject.path).to eq('/the/path')
        end
      end
    end
  end
end
