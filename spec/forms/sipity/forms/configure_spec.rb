require 'spec_helper'

module Sipity
  module Forms
    RSpec.describe Configure do
      context '.form_for_processing_entity' do
        let(:form_class) do
          Class.new do
            class << self
              def name
                'Sipity::Forms::Etd::HelloWorldForm'
              end
            end
          end
        end
        let(:base_class) { double(model_name: true, human_attribute_name: true, name: 'Sipity::Models::Work') }
        before { described_class.form_for_processing_entity(form_class: form_class, base_class: base_class) }
        subject { form_class }

        its(:policy_enforcer) { should eq(Sipity::Policies::WorkPolicy) }
        its(:base_class) { should eq(base_class) }
        its(:template) { should eq('hello_world') }

        it { should delegate_method(:model_name).to(:base_class) }
        it { should delegate_method(:human_attribute_name).to(:base_class) }
      end
    end
  end
end
