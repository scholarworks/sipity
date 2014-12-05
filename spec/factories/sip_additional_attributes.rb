FactoryGirl.define do
  factory :sip_additional_attribute, class: 'Sip::Models::AdditionalAttribute' do
    header_id 1
    key "MyString"
    value "MyString"
  end
end
