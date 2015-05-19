require 'spec_helper'

module Sipity
  module Forms
    RSpec.describe Configure do
      context '.form_for_processing_entity' do
        let(:form_class) { Class.new }
        let(:base_class) { double(model_name: true, human_attribute_name: true) }

        it 'will add .base_class to the given .form_class' do
          expect { described_class.form_for_processing_entity(form_class: form_class, base_class: base_class) }.
            to change { form_class.respond_to?(:base_class) }.from(false).to(true)
          expect(form_class.base_class).to eq(base_class)
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
