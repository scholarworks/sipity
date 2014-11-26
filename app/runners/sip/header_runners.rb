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

    # Responsible for instantiating the model for a Header
    class Show < BaseRunner
      def run(header_id, decorator: nil)
        header = repository.find_header(header_id, decorator: decorator)
        callback(:success, header)
      end
    end

    # Responsible for creating and persisting a new Header
    class Create < BaseRunner
      def run(attributes:, decorator: nil)
        header = repository.build_header(attributes: attributes, decorator: decorator)
        # TODO: Create a repository#create_header method as there could be
        # other actions/behaviors that could happen on create
        if repository.submit_create_header(header)
          callback(:success, header)
        else
          callback(:failure, header)
        end
      end
    end
  end
end
