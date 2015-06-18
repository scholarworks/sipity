require 'spec_helper'
require 'sipity'

RSpec.describe Sipity do
  subject { described_class }
  its(:table_name_prefix) { should eq('sipity_') }

  it 'exposes #t as a helper method for translations' do
    keywords = { scope: 'hello', subject: 'world' }
    expect(Sipity::Controllers::TranslationAssistant).to receive(:call).with(keywords)
    Sipity.t(keywords)
  end
end
