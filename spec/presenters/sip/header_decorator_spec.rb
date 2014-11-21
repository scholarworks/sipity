require 'spec_helper'

module Sip
  RSpec.describe HeaderDecorator do
    let(:header) { double(title: 'Hello World') }
    subject { HeaderDecorator.new(header) }
    it 'will have a #to_s equal its #title' do
      expect(subject.to_s).to eq(header.title)
    end
  end
end
