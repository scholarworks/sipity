require "rails_helper"
require 'sipity/controllers/creator_presenter'

module Sipity
  module Controllers
    RSpec.describe CreatorPresenter do
      let(:context) { PresenterHelper::Context.new(current_user: current_user, render: true) }
      let(:current_user) { double }
      let(:creator) { double(to_s: 'Hello World') }
      let(:work) { Models::Work.new(id: '1') }
      subject { described_class.new(context, work_submission: work, creator: creator) }

      its(:name) { is_expected.to eq(creator.to_s) }

      it 'will translate the identified label' do
        expect(TranslationAssistant).to receive(:call).with(scope: :predicates, object: 'name', subject: work, predicate: :label).
          and_return('My Name Is')
        expect(subject.label('name')).to eq('My Name Is')
      end
    end
  end
end
