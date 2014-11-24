module Sip
  # Container for Header related actions.
  module HeaderRunners
    # Responsible for building the model for a New Header
    class New < BaseRunner
      def run(decorator: nil)
        header = repository.build_header(decorator: decorator)
        callback(:success, header)
      end
    end
  end
end
