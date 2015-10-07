describe User do

  subject { User.new(email: 'user@example.com', name: "Hello Somebody", username: 'hello') }

  it { should respond_to(:email) }

  it 'will allow multiple users to have a "" email' do
    User.create!(username: 'one', email: '')
    expect { User.create!(username: 'two', email: '') }.to_not raise_error
  end

  its(:to_s) { should eq subject.name }

  its(:to_identifiable_agent) { should contractually_honor(Sipity::Interfaces::IdentifiableAgentInterface) }
end
