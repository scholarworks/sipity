require "rails_helper"
require 'sipity/controllers/processing_state_notice_presenter'
# Because RSpec's described_class is getting confused
require 'sipity/controllers/processing_state_notice_presenter'

module Sipity
  module Controllers
    RSpec.describe ProcessingStateNoticePresenter, type: :presenter do
      let(:context) { PresenterHelper::Context.new(current_user: current_user) }
      let(:current_user) { double('Current User') }
      let(:processing_state_notice) { double(processing_state: 'hello', can_advance_processing_state?: true) }
      subject { described_class.new(context, processing_state_notice: processing_state_notice) }

      its(:can_advance_processing_state?) { is_expected.to eq(processing_state_notice.can_advance_processing_state?) }
      its(:processing_state) { is_expected.to eq(processing_state_notice.processing_state) }

      it 'exposes message?' do
        expect(I18n).to receive(:t).with(kind_of(String), default: '').and_return('')
        expect(subject.message?).to eq(false)
      end

      context 'when you can advance the processing state' do
        let(:processing_state_notice) { double(processing_state: 'hello', can_advance_processing_state?: true) }
        its(:notice_dom_class) { is_expected.to eq('alert-success') }
        its(:message) { is_expected.to be_a(String) }
        its(:message) { is_expected.to be_html_safe }

      end

      context 'when you cannote advance the processing state' do
        let(:processing_state_notice) { double(processing_state: 'hello', can_advance_processing_state?: false) }
        its(:notice_dom_class) { is_expected.to eq('alert-info') }
        its(:message) { is_expected.to be_a(String) }
        its(:message) { is_expected.to be_html_safe }
      end
    end
  end
end
