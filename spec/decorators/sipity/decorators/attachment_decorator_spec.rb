require 'spec_helper'

module Sipity
  module Decorators
    RSpec.describe AttachmentDecorator do
      let(:attachment) { Models::Attachment.new(pid: 'abc123', file_name: "my file") }
      subject { AttachmentDecorator.new(attachment) }
      it 'will have a #to_s equal its #name' do
        expect(subject.to_s).to eq(attachment.file_name)
      end

      it 'will have a #human_attribute_name' do
        expect(subject.human_attribute_name(:name)).to eq('Name')
      end

      it 'shares .object_class with Models::Attachment' do
        expect(AttachmentDecorator.object_class).to eq(Models::Attachment)
      end
    end
  end
end
