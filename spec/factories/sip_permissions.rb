FactoryGirl.define do
  factory :sip_permission, class: 'Sip::Models::Permission' do
    user nil
    subject_id 1
    subject_type "MyString"
    role "MyString"
  end
end
