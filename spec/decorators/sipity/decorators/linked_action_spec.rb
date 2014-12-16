require 'spec_helper'

module Sipity
  module Decorators
    RSpec.describe LinkedAction do
      let(:label) { 'Hello World' }
      let(:path) { '/path/to/resource' }
      let(:html_options) { { id: 'dom_id' } }
      subject { described_class.new(label: label, path: path, html_options: html_options) }

      let(:template) { double(link_to: true) }
      it 'will render itself onto the provided template' do
        subject.render(template)
        expect(template).to have_received(:link_to).with(label, path, html_options)
      end
    end
  end
end
