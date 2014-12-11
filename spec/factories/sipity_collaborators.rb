FactoryGirl.define do
  factory :sipity_collaborator, class: 'Sipity::Models::Collaborator' do
    header_id 1
    name "MyString"
    role "MyString"
  end
end
