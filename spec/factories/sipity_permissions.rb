FactoryGirl.define do
  factory :sipity_permission, class: 'Sipity::Models::Permission' do
    user nil
    subject_id 1
    subject_type "MyString"
    role "MyString"
  end
end