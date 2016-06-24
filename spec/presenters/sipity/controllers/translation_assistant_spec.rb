require "rails_helper"
require 'sipity/controllers/translation_assistant'

module Sipity
  module Controllers
    RSpec.describe TranslationAssistant do
      let(:work_area) { Models::WorkArea.new(slug: 'fake', name: 'hello_world') }
      let(:something) { double(work_type: 'master_thesis', to_work_area: work_area, title: 'the_book') }

      it 'needs only a scope and a subject' do
        expect(described_class.call(scope: :processing_actions, subject: work_area)).
          to eq('Hello world')
      end

      it 'gracefully handles work_areas' do
        expect(described_class.call(scope: :processing_actions, subject: work_area, object: work_area, predicate: :label)).
          to eq('Hello world')
      end

      it 'gracefully handles :work_type' do
        expect(described_class.call(scope: :processing_actions, subject: something, object: something.title, predicate: :label)).
          to eq('The book')
      end

      it "will gracefully degrade if we don't have all the keys" do
        expect(I18n).to receive(:translate).and_raise(I18n::MissingInterpolationArgument.new(:key, {}, '')).at_least(1).times
        expect(Rails.logger).to receive(:debug).and_call_original.at_least(1).times
        expect(
          described_class.call(scope: :processing_actions, subject: something, object: something.title, predicate: :label)
        ).to be_a(String)
      end
    end
  end
end
