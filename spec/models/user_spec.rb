describe User do

  before(:each) { @user = User.new(email: 'user@example.com') }

  subject { @user }

  it { should respond_to(:email) }

  it "#email returns a string" do
    expect(@user.email).to match 'user@example.com'
  end

  it 'has many :permissions' do
    expect(described_class.reflect_on_association(:permissions)).
      to be_a(ActiveRecord::Reflection::AssociationReflection)
  end

end
