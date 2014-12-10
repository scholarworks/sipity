FactoryGirl.define do
  factory :sipity_permission, class: 'Sipity::Models::Permission' do
    user nil
    entity_id 1
    entity_type "MyString"
    role "MyString"
  end
end
