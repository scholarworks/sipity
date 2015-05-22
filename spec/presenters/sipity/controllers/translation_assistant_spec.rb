require 'spec_helper'

module Sipity
  module Controllers
    RSpec.describe TranslationAssistant do
      let(:work_area) { Models::WorkArea.new(slug: 'fake', name: 'hello_world') }
      let(:something) { double(work_type: 'master_thesis', to_work_area: work_area, title: 'the_book') }

      it 'gracefully handles work_areas' do
        expect(described_class.call(scope: :processing_actions, subject: work_area, object: work_area, predicate: :label)).
          to eq('Hello world')
      end

      it 'gracefully handles :work_type' do
        expect(described_class.call(scope: :processing_actions, subject: something, object: something.title, predicate: :label)).
          to eq('The book')
      end
    end
  end
end
