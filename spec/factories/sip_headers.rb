FactoryGirl.define do
  factory :sip_header, :class => 'Sip::Header' do
    work_publication_strategy "MyString"
title "MyString"
  end

end
