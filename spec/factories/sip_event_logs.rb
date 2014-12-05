FactoryGirl.define do
  factory :sip_event_log, class: 'Sip::Models::EventLog' do
    user 1
    subject_id 1
    subject_type "MyString"
    event_name "MyString"
  end
end
