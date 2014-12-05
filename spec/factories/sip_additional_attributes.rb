FactoryGirl.define do
  factory :sip_additional_attribute, class: 'Sipity::Models::AdditionalAttribute' do
    header_id 1
    key "MyString"
    value "MyString"
  end
end
