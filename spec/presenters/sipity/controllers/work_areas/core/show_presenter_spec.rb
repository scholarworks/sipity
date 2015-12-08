require 'spec_helper'
require 'sipity/controllers/work_areas/core/show_presenter'

module Sipity
  module Controllers
    module WorkAreas
      module Core
        RSpec.describe ShowPresenter do
          subject { described_class }
          its(:superclass) { should eq(Sipity::Controllers::Visitors::Core::WorkAreaPresenter) }
        end
      end
    end
  end
end
