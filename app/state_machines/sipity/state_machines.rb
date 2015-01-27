# Because of the `const_defined?` I'm requiring the various sipity state
# machines
named_concept = File.basename(__FILE__, '.rb')
Dir[File.expand_path("../#{named_concept}/*.rb", __FILE__)].each do |filename|
  require_relative "./#{named_concept}/#{File.basename(filename)}"
end

module Sipity
  # Container for all StateMachines
  module StateMachines
    module_function

    def find_state_machine_for(work_type:)
      state_machine_name_by_convention = "#{work_type.classify}StateMachine"
      if const_defined?(state_machine_name_by_convention)
        const_get(state_machine_name_by_convention)
      else
        fail Exceptions::StateMachineNotFoundError, name: state_machine_name_by_convention, container: self
      end
    end
  end
end
