describe User do

  before(:each) { @user = User.new(email: 'user@example.com') }

  subject { @user }

  it { should respond_to(:email) }

  it "#email returns a string" do
    expect(@user.email).to match 'user@example.com'
  end

  it 'will allow multiple users to have a "" email' do
    User.create!(username: 'one', email: '')
    expect { User.create!(username: 'two', email: '') }.to_not raise_error
  end

end
