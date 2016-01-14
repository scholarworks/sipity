require 'spec_helper'

RSpec.describe Sipity::DataGenerators::WorkTypeSchema do
  subject { described_class.new }

  context 'with valid data' do
    let(:data) do
      {
        work_types: [
          {
            name: 'ulra_submission',
            strategy_permissions: [
              { group: 'ULRA Review Committee', role: 'ulra_reviewer' }
            ],
            actions: [
              {
                name: 'start_a_submission',
                transition_to: 'new',
                emails: [
                  { name: 'confirmation_of_ulra_submission_started', to: ['creating_user'] },
                  { name: 'faculty_assigned_for_ulra_submission', to: ['advisor'] }
                ],
                states: [
                  { name: 'under_review', roles: 'ulra_reviewer' },
                  { name: 'something_else', roles: ['ulra_reviewer'] }
                ],
                attributes: { presentation_sequence: 1 },
                required_actions: ['something']
              }, {
                name: 'something',
                transition_to: 'new',
                states: [
                  { name: 'something_else', roles: ['ulra_reviewer'] }
                ]
              }
            ],
            state_emails: [
              {
                state: 'under_review',
                reason: 'processing_hook_triggered',
                emails: [
                  { name: 'student_has_indicated_attachments_are_complete', to: 'ulra_reviewer' }
                ]
              }
            ],
            action_analogues: [
              { action: 'start_a_submission', analogous_to: 'something' }
            ]
          }
        ]
      }
    end

    it 'validates good data' do
      expect(subject.call(data).messages).to be_empty
    end

    [
      "ulra_work_types.json",
      "etd_work_types.json"
    ].each do |basename|
      it "validates #{basename}" do
        data = JSON.parse(Rails.root.join('app/data_generators/sipity/data_generators/work_types', basename).read)
        data.deep_symbolize_keys!
        expect(subject.call(data).messages).to be_empty
      end
    end
  end
end
