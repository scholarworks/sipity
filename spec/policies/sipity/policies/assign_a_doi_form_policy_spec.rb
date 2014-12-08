require 'spec_helper'

module Sipity
  module Policies
    RSpec.describe AssignADoiFormPolicy do
      let(:user) { User.new(id: '1') }
      let(:header) { Models::Header.new(id: '2') }
      let(:form) { Forms::AssignADoiForm.new(header: header) }
      let(:header_policy) { double('Header Policy') }
      subject { AssignADoiFormPolicy.new(user, form, header_policy: header_policy) }

      it 'will have a default header_policy' do
        expect(AssignADoiFormPolicy.new(user, form).send(:header_policy)).to be_a(HeaderPolicy)
      end

      context 'for a non-authenticated user' do
        let(:user) { nil }
        its(:submit?) { should eq(false) }
      end

      context 'for an authenticated user' do
        context 'with a new header' do
          before { allow(header).to receive(:persisted?).and_return(false) }
          its(:submit?) { should eq(false) }
        end
        context 'with an existing header' do
          before do
            allow(header).to receive(:persisted?).and_return(true)
          end
          context 'its :submit?' do
            it 'will delegate to the provided header_policy' do
              expect(header_policy).to receive(:update?).and_return(true)
              expect(subject.submit?).to eq(true)
            end
          end
        end
      end
    end
  end
end
