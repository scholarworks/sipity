require "rails_helper"
require 'sipity/controllers/translation_assistant_for_polymorphic_type'

module Sipity
  module Controllers
    RSpec.describe TranslationAssistantForPolymorphicType do
      let(:work_area) { Models::WorkArea.new(slug: 'fake', name: 'hello_world') }
      let(:something) { double(work_type: 'master_thesis', to_work_area: work_area, title: 'the_book') }

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
