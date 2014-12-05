require 'spec_helper'

module Sip
  module Decorators
    RSpec.describe CollaboratorDecorator do
      let(:header) { double(name: 'Hello World') }
      subject { CollaboratorDecorator.new(header) }
      it 'will have a #to_s equal its #name' do
        expect(subject.to_s).to eq(header.name)
      end
    end
  end
end
