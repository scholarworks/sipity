FactoryGirl.define do
  factory :sip_header, class: 'Sip::Models::Header' do
    title "MyString"
    work_publication_strategy "do_not_know"
  end
end
