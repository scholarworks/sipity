module Sipity
  module Runners
    # Container for Header related actions.
    module HeaderRunners
      # Responsible for building the model for a New Header
      class New < BaseRunner
        self.requires_authentication = true
        self.enforces_authorization = true

        def run
          header = repository.build_create_header_form
          authorization_layer.enforce!(create?: header) do
            callback(:success, header)
          end
        end
      end

      # Responsible for creating and persisting a new Header
      class Create < BaseRunner
        self.requires_authentication = true
        self.enforces_authorization = true

        def run(attributes:)
          form = repository.build_create_header_form(attributes: attributes)
          authorization_layer.enforce!(create?: form) do
            header = repository.submit_create_header_form(form, requested_by: current_user)
            if header
              callback(:success, header)
            else
              callback(:failure, form)
            end
          end
        end
      end

      # Responsible for instantiating the model for a Header
      class Show < BaseRunner
        self.requires_authentication = true
        self.enforces_authorization = true

        def run(header_id:)
          header = repository.find_header(header_id)
          authorization_layer.enforce!(show?: header) do
            callback(:success, header)
          end
        end
      end

      # Responsible for providing an index of Headers
      class Index < BaseRunner
        self.requires_authentication = true

        def run
          headers = repository.find_headers_for(user: current_user)
          callback(:success, headers)
        end
      end

      # Responsible for instantiating the header for edit
      class Edit < BaseRunner
        self.requires_authentication = true
        self.enforces_authorization = true

        def run(header_id:)
          header = repository.find_header(header_id)
          form = repository.build_update_header_form(header: header)
          authorization_layer.enforce!(submit?: form) do
            callback(:success, form)
          end
        end
      end

      # Responsible for creating and persisting a new Header
      class Update < BaseRunner
        self.requires_authentication = true
        self.enforces_authorization = true

        def run(header_id:, attributes:)
          header = repository.find_header(header_id)
          form = repository.build_update_header_form(header: header, attributes: attributes)
          authorization_layer.enforce!(submit?: form) do
            header = repository.submit_update_header_form(form, requested_by: current_user)
            if header
              callback(:success, header)
            else
              callback(:failure, form)
            end
          end
        end
      end
    end
  end
end
