module Sipity
  module Runners
    # Container for Header related actions.
    module HeaderRunners
      # Responsible for building the model for a New Header
      class New < BaseRunner
        self.requires_authentication = true
        self.policy_question = :create?

        def run
          header = repository.build_create_header_form
          if repository.policy_unauthorized_for?(runner: self, entity: header)
            callback(:unauthorized)
          else
            callback(:success, header)
          end
        end
      end

      # Responsible for instantiating the model for a Header
      class Show < BaseRunner
        self.requires_authentication = true
        self.policy_question = :show?

        def run(header_id)
          header = repository.find_header(header_id)
          if repository.policy_unauthorized_for?(runner: self, entity: header)
            callback(:unauthorized)
          else
            callback(:success, header)
          end
        end
      end

      # Responsible for creating and persisting a new Header
      class Create < BaseRunner
        self.requires_authentication = true

        def run(attributes:)
          form = repository.build_create_header_form(attributes: attributes)
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
        self.requires_authentication = true

        def run(header_id)
          header = repository.find_header(header_id)
          form = repository.build_edit_header_form(header: header)
          callback(:success, form)
        end
      end

      # Responsible for creating and persisting a new Header
      class Update < BaseRunner
        self.requires_authentication = true

        def run(header_id, attributes:)
          header = repository.find_header(header_id)
          form = repository.build_edit_header_form(header: header, attributes: attributes)
          header = repository.submit_edit_header_form(form)
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
