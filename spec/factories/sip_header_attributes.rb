FactoryGirl.define do
  factory :sip_header_attribute, class: 'Sip::HeaderAttribute' do
    header_id 1
    key "MyString"
    value "MyString"
  end
end
