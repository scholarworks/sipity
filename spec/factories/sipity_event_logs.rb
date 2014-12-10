FactoryGirl.define do
  factory :sipity_event_log, class: 'Sipity::Models::EventLog' do
    user 1
    entity_id 1
    entity_type "MyString"
    event_name "MyString"
  end
end
