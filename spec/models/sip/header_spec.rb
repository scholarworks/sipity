require 'rails_helper'

module Sip
  RSpec.describe Header, type: :model do
    subject { Header.new }
    context '.work_publication_strategies' do
      it 'is a Hash of keys that equal their values' do
        expect(Header.work_publication_strategies.keys).
          to eq(Header.work_publication_strategies.values)
      end
    end
  end
end
