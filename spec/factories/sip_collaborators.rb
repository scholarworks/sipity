FactoryGirl.define do
  factory :sip_collaborator, class: 'Sip::Collaborator' do
    sip_header_id 1
    name "MyString"
    role "MyString"
  end
end
