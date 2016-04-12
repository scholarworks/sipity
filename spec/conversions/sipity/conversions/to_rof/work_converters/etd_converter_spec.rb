require 'spec_helper'
require 'sipity/conversions/to_rof/work_converters/etd_converter'
require 'support/shared_examples/a_work_to_rof_converter'

module Sipity
  module Conversions
    module ToRof
      module WorkConverters
        RSpec.describe EtdConverter do
          it_behaves_like 'a work to rof converter', af_model: 'Etd', attachment_predicate_name: :all
        end
      end
    end
  end
end
