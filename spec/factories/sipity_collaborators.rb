FactoryGirl.define do
  factory :sipity_collaborator, class: 'Sipity::Models::Collaborator' do
    sipity_header_id 1
    name "MyString"
    role "MyString"
  end
end
