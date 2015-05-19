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

        it 'will add .base_class to the given .form_class' do
          expect { described_class.form_for_processing_entity(form_class: form_class, base_class: base_class) }.
            to change { form_class.respond_to?(:base_class) }.from(false).to(true)
          expect(form_class.base_class).to eq(base_class)
        end

        it 'will add .policy_enforcer to the given .form_class' do
          expect { described_class.form_for_processing_entity(form_class: form_class, base_class: base_class) }.
            to change { form_class.respond_to?(:policy_enforcer) }.from(false).to(true)
          expect(form_class.policy_enforcer).to eq(Sipity::Policies::WorkPolicy)
        end

        it 'will add .template to the given .form_class' do
          expect { described_class.form_for_processing_entity(form_class: form_class, base_class: base_class) }.
            to change { form_class.respond_to?(:template) }.from(false).to(true)
          expect(form_class.template).to eq('hello_world')
        end

        it 'will delegate .model_name to the given .form_class' do
          described_class.form_for_processing_entity(form_class: form_class, base_class: base_class)
          form_class.model_name
          expect(base_class).to have_received(:model_name)
        end

        it 'will delegate .human_attribute_name to the given .form_class' do
          described_class.form_for_processing_entity(form_class: form_class, base_class: base_class)
          form_class.human_attribute_name
          expect(base_class).to have_received(:human_attribute_name)
        end
      end
    end
  end
end
