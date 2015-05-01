require 'spec_helper'

module Sipity
  module Forms
    RSpec.describe WorkAreaForms do
      subject { described_class }
      it { should respond_to :build_the_form }
    end
  end
end
