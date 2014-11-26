require 'spec_helper'

module Sip
  module Recommendations
    RSpec.describe Base do
      let(:header) { double('Header', title: 'My Title') }
      let(:helper) { double('Helper') }
      let(:repository) { double('Repository') }
      subject { described_class.new(header: header, helper: helper, repository: repository) }

      context 'upon extension' do
        it 'will require you to implement #path_to_recommendation' do
          expect { subject.path_to_recommendation }.to raise_error(NotImplementedError)
        end
        it 'will require you to implement #state' do
          expect { subject.state }.to raise_error(NotImplementedError)
        end
      end

      context 'when extended' do
        before do
          class TestClass < described_class
            def state
              :complete
            end
          end
        end
        after do
          Sip::Recommendations.send(:remove_const, :TestClass)
        end
        subject { TestClass.new(header: header, helper: helper, repository: repository) }
        it 'has a translated #human_status' do
          expect(subject.human_status).to eq("translation missing: en.sip/recommendations/test_class.state.#{subject.state}")
        end
        it 'has a translated #human_name' do
          expect(subject.human_name).to eq("translation missing: en.sip/recommendations/test_class.name")
        end

        it 'has a translated #human_attribute_name' do
          expect(subject.human_attribute_name(:some_attribute)).to eq("Some attribute")
        end
      end
    end
  end
end
