require 'spec_helper'

module Sipity
  module Forms
    RSpec.describe WorkAreaForms do
      subject { described_class }
      it { should respond_to :build_the_form }

      context '#build_the_form' do
        xit 'will use the work area and action name to find the correct object'
      end
    end
  end
end
