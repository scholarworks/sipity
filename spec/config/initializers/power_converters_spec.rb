require 'rails_helper'

RSpec.describe 'power converters' do
  context 'access_url' do
    [
      {
        to_convert: Sipity::Models::Attachment.create!(file: File.new(__FILE__), work_id: 1, pid: 2, predicate_name: 'attachment'),
        expected: %r{http://localhost:3000/attachments/\w+}
      }, {
        to_convert: Sipity::Models::WorkArea.new(slug: 'wa-slug'),
        expected: "http://localhost:3000/areas/wa-slug"
      }, {
        to_convert: Sipity::Models::SubmissionWindow.new(slug: 'sw-slug', work_area: Sipity::Models::WorkArea.new(slug: 'wa-slug')),
        expected: "http://localhost:3000/areas/wa-slug/sw-slug"
      }, {
        to_convert: Sipity::Models::Work.new(id: 'w-id'),
        expected: "http://localhost:3000/work_submissions/w-id"
      }
    ].each do |scenario|
      it "will convert #{scenario.fetch(:to_convert).inspect} to '#{scenario.fetch(:expected)}'" do
        expect(PowerConverter.convert(scenario.fetch(:to_convert), to: :access_url)).to match(scenario.fetch(:expected))
      end
    end

    it 'will not convert a string' do
      expect { PowerConverter.convert("Your Unconvertable", to: :access_url) }.
        to raise_error(PowerConverter::ConversionError)
    end
  end

  context 'access_url' do
    [
      {
        to_convert: Sipity::Models::WorkArea.new(slug: 'wa-slug'),
        expected: "/areas/wa-slug"
      }, {
        to_convert: Sipity::Models::SubmissionWindow.new(slug: 'sw-slug', work_area: Sipity::Models::WorkArea.new(slug: 'wa-slug')),
        expected: "/areas/wa-slug/sw-slug"
      }, {
        to_convert: Sipity::Models::Work.new(id: 'w-id'),
        expected: "/work_submissions/w-id"
      }
    ].each do |scenario|
      it "will convert #{scenario.fetch(:to_convert).inspect} to '#{scenario.fetch(:expected)}'" do
        expect(PowerConverter.convert(scenario.fetch(:to_convert), to: :access_path)).to match(scenario.fetch(:expected))
      end
    end

    it 'will not convert an attachment' do
      object = Sipity::Models::Attachment.create!(file: File.new(__FILE__), work_id: 1, pid: 2, predicate_name: 'attachment')
      expect { PowerConverter.convert(object, to: :access_path) }.
        to raise_error(PowerConverter::ConversionError)
    end
  end

  context 'authentication_agent' do
    it 'will convert an object that adhears to the AgentInterface' do
      object = double(email: true, ids: [], name: 'hello', user_signed_in?: true, agreed_to_application_terms_of_service?: true)
      expect(PowerConverter.convert(object, to: :authentication_agent)).to eq(object)
    end

    it 'will convert a persisted User to an Agent' do
      user = User.new(username: 'hello')
      expect(PowerConverter.convert(user, to: :authentication_agent)).to be_a(Sipity::Models::AuthenticationAgent::FromDevise)
    end

    it 'will not convert any old object' do
      object = double('An object')
      expect { PowerConverter.convert(object, to: :authentication_agent) }.
        to raise_error(PowerConverter::ConversionError)
    end
  end

  context 'boolean' do
    [
      ['1', true],
      ["11", true],
      ["0", false],
      [0, false],
      [1, true],
      ['true', true],
      ['false', false],
      [nil, false],
      [Object.new, true]
    ].each_with_index do |(to_convert, expected), index|
      it "will convert #{to_convert.inspect} to #{expected} (Scenario ##{index}" do
        expect(PowerConverter.convert_to_boolean(to_convert)).to eq(expected)
      end
    end
  end

  context ':identifiable_agent' do
    it 'will convert an object that implements the interface' do
      object = Sipity::Models::IdentifiableAgent.new_for_identifier_id(identifier_id: 'RXLB3MeFcsUbaDIX0I_38g==')
      expect(PowerConverter.convert(object, to: :identifiable_agent)).to eq(object)
    end

    it 'will convert a well formed identifier_id' do
      identifier_id = 'bmV0aWQJamZyaWVzZW4='
      expect(
        PowerConverter.convert(identifier_id, to: :identifiable_agent)
      ).to contractually_honor(Sipity::Interfaces::IdentifiableAgentInterface)
    end

    it 'will raise on a mal-formed' do
      expect { PowerConverter.convert('junk', to: :identifiable_agent) }.to raise_error(PowerConverter::ConversionError)
    end
  end

  context ':identifier_id' do
    it 'will convert a Processing::Actor' do
      actor = Sipity::Models::Processing::Actor.new(proxy_for: User.new(username: 'hello'))
      expect(PowerConverter.convert(actor, to: :identifier_id)).to be_a(String)
    end
    it 'will convert a user with a username' do
      user = User.new(username: 'hello')
      expect(PowerConverter.convert(user, to: :identifier_id)).to be_a(String)
    end
    it 'will allow a properly encoding string to pass' do
      identifier_id = Cogitate::Client.encoded_identifier_for(strategy: 'netid', identifying_value: 'hworld')
      expect(PowerConverter.convert(identifier_id, to: :identifier_id)).to eq(identifier_id)
    end
    it 'will not allow an improperly encoded string to pass' do
      bad_identifier_id = 'chicken_soup'
      expect { PowerConverter.convert(bad_identifier_id, to: :identifier_id) }.to raise_error(PowerConverter::ConversionError)
    end
    it 'will not convert a user with a username' do
      user = User.new
      expect { PowerConverter.convert(user, to: :identifier_id) }.to raise_error(PowerConverter::ConversionError)
    end
    it 'will convert a group with a name' do
      group = Sipity::Models::Group.new(name: 'hello')
      expect(PowerConverter.convert(group, to: :identifier_id)).to be_a(String)
    end
    it 'will not convert a group without a name' do
      group = Sipity::Models::Group.new
      expect { PowerConverter.convert(group, to: :identifier_id) }.to raise_error(PowerConverter::ConversionError)
    end
    it 'will convert a collaborator with an email' do
      collaborator = Sipity::Models::Collaborator.new(email: 'hello')
      expect(PowerConverter.convert(collaborator, to: :identifier_id)).to be_a(String)
    end
    it 'will convert a collaborator with an identifier_id' do
      collaborator = Sipity::Models::Collaborator.new(identifier_id: 'hello')
      expect(PowerConverter.convert(collaborator, to: :identifier_id)).to eq('hello')
    end
    it 'will not convert a collaborator without an email' do
      collaborator = Sipity::Models::Collaborator.new
      expect { PowerConverter.convert(collaborator, to: :identifier_id) }.to raise_error(PowerConverter::ConversionError)
    end
    it 'will convert a Cogitate::Models::IdentifiableAgent' do
      agent = Cogitate::Models::Agent.build_with_identifying_information(strategy: 'group', identifying_value: '123')
      expect(PowerConverter.convert(agent, to: :identifier_id)).to be_a(String)
    end
    it 'will convert a Cogitate::Models::Identifier' do
      identifier = Cogitate::Models::Identifier.new(strategy: 'group', identifying_value: '123')
      expect(PowerConverter.convert(identifier, to: :identifier_id)).to be_a(String)
    end
  end

  context 'strategy_state' do
    let(:strategy_state) { Sipity::Models::Processing::StrategyState.new(id: 1, name: 'hello') }
    let(:strategy) { Sipity::Models::Processing::Strategy.new(id: 2, name: 'strategy') }
    it 'will convert a Processing::Model::StrategyState' do
      expect(PowerConverter.convert(strategy_state, to: :strategy_state)).to eq(strategy_state)
    end

    it 'will convert a string based on scope' do
      Sipity::Models::Processing::StrategyState.create!(strategy_id: strategy.id, name: 'hello')
      PowerConverter.convert('hello', scope: strategy, to: :strategy_state)
    end

    it 'will attempt convert a string based on scope' do
      expect { PowerConverter.convert('missing', scope: strategy, to: :strategy_state) }.
        to raise_error(PowerConverter::ConversionError)
    end
  end

  context 'processing_comment' do
    it 'will convert a Processing Comment' do
      object = Sipity::Models::Processing::Comment.new
      expect(PowerConverter.convert(object, to: :processing_comment)).to eq(object)
    end

    it 'will convert a Processing EntityActionRegister subject' do
      object = Sipity::Models::Processing::Comment.new
      register = Sipity::Models::Processing::EntityActionRegister.new(subject: object)
      expect(PowerConverter.convert(register, to: :processing_comment)).to eq(object)
    end

    it 'will fail if Processing EntityActionRegister subject is not a comment' do
      object = Sipity::Models::Work.new
      register = Sipity::Models::Processing::EntityActionRegister.new(subject: object)
      expect { PowerConverter.convert(register, to: :processing_comment) }.
        to raise_error(PowerConverter::ConversionError)
    end

    it 'will fail to convert a string' do
      expect { PowerConverter.convert('missing', to: :processing_comment) }.
        to raise_error(PowerConverter::ConversionError)
    end
  end

  [:slug].each do |named_converter|
    context named_converter.to_s do
      [
        { to_convert: 'Hello World', expected: 'hello-world' },
        { to_convert: 'HelloWorld', expected: 'hello-world' },
        { to_convert: '', expected: '' },
        { to_convert: nil, expected: '' }
      ].each do |scenario|
        it "will convert #{scenario.fetch(:to_convert)} to #{scenario.fetch(:expected)}" do
          expect(PowerConverter.convert(scenario.fetch(:to_convert), to: named_converter)).to eq(scenario.fetch(:expected))
        end
      end
    end
  end

  [:file_system_safe_file_name].each do |named_converter|
    context named_converter.to_s do
      [
        { to_convert: 'Hello World', expected: 'hello_world' },
        { to_convert: 'HelloWorld', expected: 'hello_world' },
        { to_convert: '', expected: '' },
        { to_convert: nil, expected: '' }
      ].each do |scenario|
        it "will convert #{scenario.fetch(:to_convert)} to #{scenario.fetch(:expected)}" do
          expect(PowerConverter.convert(scenario.fetch(:to_convert), to: named_converter)).to eq(scenario.fetch(:expected))
        end
      end
    end
  end

  [:safe_for_method_name].each do |named_converter|
    context named_converter.to_s do
      [
        { to_convert: 'Hello World', expected: 'hello_world' },
        { to_convert: 'HelloWorld', expected: 'hello_world' }
      ].each do |scenario|
        it "will convert #{scenario.fetch(:to_convert)} to #{scenario.fetch(:expected)}" do
          expect(PowerConverter.convert(scenario.fetch(:to_convert), to: named_converter)).to eq(scenario.fetch(:expected))
        end
      end

      [
        ''
      ].each do |to_convert_but_will_fail|
        it "will fail to convert #{to_convert_but_will_fail.inspect}" do
          expect { PowerConverter.convert(to_convert_but_will_fail, to: named_converter) }.to raise_error(PowerConverter::ConversionError)
        end
      end
    end
  end

  context "demodulized_class_name" do
    [
      { to_convert: 'Hello World', expected: 'HelloWorld' },
      { to_convert: 'HelloWorld', expected: 'HelloWorld' },
      { to_convert: 'HelloWorlds', expected: 'HelloWorld' },
      { to_convert: nil, expected: '' },
      { to_convert: 'hello World/Somebody', expected: 'HelloWorldSomebody' }
    ].each do |scenario|
      it "will convert #{scenario.fetch(:to_convert)} to #{scenario.fetch(:expected)}" do
        expect(PowerConverter.convert(scenario.fetch(:to_convert), to: :demodulized_class_name)).to eq(scenario.fetch(:expected))
      end
    end
  end

  context 'role' do
    it "will convert Sipity::Models::Role" do
      object = Sipity::Models::Role.new
      expect(PowerConverter.convert(object, to: :role)).to eq(object)
    end

    it "will convert a #to_role object" do
      object = double(to_role: Sipity::Models::Role.new)
      expect(PowerConverter.convert(object, to: :role)).to eq(object.to_role)
    end

    it "will convert a valid string" do
      object = Sipity::Models::Role::CREATING_USER
      expect(PowerConverter.convert(object, to: :role)).to be_a(Sipity::Models::Role)
    end

    it "will convert a base object with composed attributes delegator" do
      base_object = Sipity::Models::Role.new
      object = Sipity::Decorators::BaseObjectWithComposedAttributesDelegator.new(base_object)
      expect(PowerConverter.convert(object, to: :role)).to eq(base_object)
    end

    it 'will not convert a string' do
      expect { PowerConverter.convert("Your Unconvertable", to: :role) }.
        to raise_error(PowerConverter::ConversionError)
    end
  end

  context 'role_name' do
    it "will convert Sipity::Models::Role" do
      object = Sipity::Models::Role.new(name: 'creating_user')
      expect(PowerConverter.convert(object, to: :role_name)).to eq(object.name)
    end

    it "will convert a #to_role object" do
      object = double(to_role_name: 'Chicken')
      expect(PowerConverter.convert(object, to: :role_name)).to eq(object.to_role_name)
    end

    it "will convert a valid string" do
      object = Sipity::Models::Role::CREATING_USER
      expect(PowerConverter.convert(object, to: :role_name)).to eq(object)
    end

    it "will convert a base object with composed attributes delegator" do
      base_object = Sipity::Models::Role.new(name: 'creating_user')
      object = Sipity::Decorators::BaseObjectWithComposedAttributesDelegator.new(base_object)
      expect(PowerConverter.convert(object, to: :role_name)).to eq(base_object.name)
    end

    it 'will not convert an empty string' do
      expect { PowerConverter.convert("", to: :role_name) }.
        to raise_error(PowerConverter::ConversionError)
    end

    it 'will not convert an invalid Role name' do
      expect { PowerConverter.convert("soft_taco", to: :role_name) }.
        to raise_error(PowerConverter::ConversionError)
    end
  end

  context "work_type" do
    let(:a_work_type) { Sipity::Models::WorkType.new }
    it 'will attempt to find the given String' do
      expect(Sipity::Models::WorkType).to receive(:find_or_create_by!).with(name: 'doctoral_dissertation').and_return(a_work_type)
      expect(PowerConverter.convert('doctoral_dissertation', to: :work_type)).to eq(a_work_type)
    end

    it 'will attempt to find the given Symbol' do
      expect(Sipity::Models::WorkType).to receive(:find_or_create_by!).with(name: 'doctoral_dissertation').and_return(a_work_type)
      expect(PowerConverter.convert(:doctoral_dissertation, to: :work_type)).to eq(a_work_type)
    end

    it 'will raise an error if not found' do
      expect { PowerConverter.convert(:chicken, to: :work_type) }.
        to raise_error(PowerConverter::ConversionError)
    end

    it 'will create if we have a valid work type' do
      expect(PowerConverter.convert(:doctoral_dissertation, to: :work_type)).to be_a(Sipity::Models::WorkType)
    end

    it 'will pass through a given WorkType' do
      expect(PowerConverter.convert(a_work_type, to: :work_type)).to eq(a_work_type)
    end
  end

  context 'work_area' do
    it "will convert based on the given scenarios" do

      # Putting these all in one scenario as there is a database hit that occurs
      # It breaks the "convention" of one assertion per spec, but speed is nice.

      work_area = Sipity::Models::WorkArea.create!(
        name: 'The Name', slug: 'the-slug', partial_suffix: 'the-partial-suffix', demodulized_class_prefix_name: 'TheName'
      )
      [
        { to_convert: 'The Name', expected_name: 'The Name' },
        { to_convert: 'the-slug', expected_name: 'The Name' }
      ].each do |scenario|
        to_convert = scenario.fetch(:to_convert)
        expect(PowerConverter.convert_to_work_area(to_convert).name).to eq(scenario.fetch(:expected_name))
      end

      expect(PowerConverter.convert_to_work_area(work_area)).to eq(work_area)
      submission_window = Sipity::Models::SubmissionWindow.new(work_area: work_area)
      expect(PowerConverter.convert_to_work_area(submission_window)).to eq(work_area)
      work = Sipity::Models::Work.new
      allow(work).to receive(:work_area).and_return(work_area)
      expect(PowerConverter.convert_to_work_area(work)).to eq(work_area)
      entity = Sipity::Models::Processing::Entity.new(proxy_for: work)
      expect(PowerConverter.convert_to_work_area(entity)).to eq(work_area)

      [
        'The Missing Name'
      ].each do |to_convert_but_will_fail|
        expect { PowerConverter.convert_to_work_area(to_convert_but_will_fail) }.to raise_error(PowerConverter::ConversionError)
      end
    end
  end

  context 'submission_window' do
    it "will convert based on the given scenarios" do

      work_area = Sipity::Models::WorkArea.new(id: 1)
      submission_window = Sipity::Models::SubmissionWindow.new(id: 2, slug: 'slug', work_area_id: work_area.id)
      expect(PowerConverter.convert(submission_window, to: :submission_window, scope: work_area)).to eq(submission_window)

      # Without scope as a consideration
      expect(PowerConverter.convert(submission_window, to: :submission_window)).to eq(submission_window)

      work = Sipity::Models::Work.new(id: 8)
      allow(work).to receive(:submission_window).and_return(submission_window)
      expect(PowerConverter.convert(work, to: :submission_window)).to eq(submission_window)

      expect { PowerConverter.convert(submission_window, to: :submission_window, scope: Sipity::Models::WorkArea.new(id: 822)) }.
        to raise_error(PowerConverter::ConversionError)
    end
  end

  context 'processing_action_root_path' do
    [
      {
        to_convert: Sipity::Models::WorkArea.new(slug: 'wa-slug'),
        expected: "/areas/wa-slug/do"
      }, {
        to_convert: Sipity::Models::SubmissionWindow.new(slug: 'sw-slug', work_area: Sipity::Models::WorkArea.new(slug: 'wa-slug')),
        expected: "/areas/wa-slug/sw-slug/do"
      }, {
        to_convert: Sipity::Models::Work.new(id: 'w-id'),
        expected: "/work_submissions/w-id/do"
      }
    ].each do |scenario|
      it "will convert #{scenario.fetch(:to_convert).inspect} to '#{scenario.fetch(:expected)}'" do
        expect(PowerConverter.convert(scenario.fetch(:to_convert), to: :processing_action_root_path)).to eq(scenario.fetch(:expected))
      end
    end

    it 'will not convert a string' do
      expect { PowerConverter.convert("Your Unconvertable", to: :processing_action_root_path) }.
        to raise_error(PowerConverter::ConversionError)
    end
  end
end
