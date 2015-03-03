require 'spec_helper'

module Sipity
  module Decorators
    RSpec.describe EmailNotificationDecorator do
      let(:entity) { Models::Work.new(id: '123', work_type: 'doctoral_dissertation') }

      subject { described_class.new(entity) }

      it { should respond_to(:netid) }
      it { should respond_to(:creator) }
      it { should respond_to(:director) }
      it { should respond_to(:document_type) }
      it { should respond_to(:approval_date) }
      it { should respond_to(:approved_by_directors) }
      it { should respond_to(:review_link_for_grad_school) }
      it { should respond_to(:review_link_for_advisor) }
      it { should respond_to(:permission_for_third_party_materials) }
      it { should respond_to(:comments) }
      it { should respond_to(:curate_link) }
      it { should respond_to(:degree) }
      it { should respond_to(:graduate_programs) }
      it { should respond_to(:release_date) }
      it { should respond_to(:access_rights) }
      it { should respond_to(:will_be_released_to_the_public?) }
      it 'shares .object_class with Models::Work' do
        expect(EmailNotificationDecorator.object_class).to eq(Models::Work)
      end

      its(:document_type) { should eq(entity.work_type.humanize) }

      it 'will have a #work_show_path' do
        expect(subject.work_show_path).to be_a(String)
      end

      context 'with "open_access" rights' do
        Given(:answer) { 'open_access' }
        When(:rights) { Models::AccessRight.create(entity: entity, access_right_code: answer, enforcement_start_date: Date.today) }
        Then { subject.access_rights.should eq(answer.titleize) }
      end

    end
  end
end
