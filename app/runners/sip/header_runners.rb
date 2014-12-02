module Sip
  # Container for Header related actions.
  module HeaderRunners
    # Responsible for building the model for a New Header
    class New < BaseRunner
      def run(decorator: nil)
        header = repository.build_create_header_form(decorator: decorator)
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
        form = repository.build_create_header_form(attributes: attributes, decorator: decorator)
        header = repository.submit_create_header_form(form)
        if header
          callback(:success, header)
        else
          callback(:failure, form)
        end
      end
    end

    # Responsible for instantiating the header for edit
    class Edit < BaseRunner
      def run(header_id:)
        header = repository.find_header(header_id)
        callback(:success, header)
      end
    end
  end
end
