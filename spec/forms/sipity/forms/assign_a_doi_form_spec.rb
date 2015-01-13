require 'spec_helper'

module Sipity
  module Forms
    RSpec.describe AssignADoiForm do
      let(:work) { double('Sip') }

      subject { described_class.new(work: work) }

      it 'requires a work' do
        subject = described_class.new(work: nil, decorator: nil)
        subject.valid?
        expect(subject.errors[:work]).to_not be_empty
      end

      it 'requires an identifer' do
        subject.valid?
        expect(subject.errors[:identifier]).to_not be_empty
      end

      its(:identifier_key) { should be_a(String) }
      its(:assign_a_doi_form) { should be_a AssignADoiForm }
      its(:request_a_doi_form) { should be_a RequestADoiForm }
    end
  end
end
