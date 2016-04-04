describe User do

  subject { User.new(email: 'user@example.com', name: "Hello Somebody") }

  it { is_expected.to respond_to(:email) }

  it { expect(User.create!(username: 'bogus', email: '')).to callback(:call_on_create_user_service).after(:commit) }

  it 'will allow multiple users to have a "" email' do
    User.create!(username: 'one', email: '')
    expect { User.create!(username: 'two', email: '') }.to_not raise_error
  end

  its(:to_s) { is_expected.to eq subject.name }

end
