module Sipity
  module Runners
    # Container for Sip related actions.
    module SipRunners
      # Responsible for building the model for a New Sip
      class New < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :default

        def run(attributes: {})
          sip = repository.build_create_sip_form(attributes: attributes)
          authorization_layer.enforce!(create?: sip) do
            callback(:success, sip)
          end
        end
      end

      # Responsible for creating and persisting a new Sip
      class Create < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :default

        def run(attributes:)
          form = repository.build_create_sip_form(attributes: attributes)
          authorization_layer.enforce!(create?: form) do
            sip = repository.submit_create_sip_form(form, requested_by: current_user)
            if sip
              callback(:success, sip)
            else
              callback(:failure, form)
            end
          end
        end
      end

      # Responsible for instantiating the model for a Sip
      class Show < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :default

        def run(sip_id:)
          sip = repository.find_sip(sip_id)
          authorization_layer.enforce!(show?: sip) do
            callback(:success, sip)
          end
        end
      end

      # Responsible for providing an index of Sips
      class Index < BaseRunner
        self.authentication_layer = :default

        def run
          sips = repository.find_sips_for(user: current_user)
          callback(:success, sips)
        end
      end

      # Responsible for instantiating the sip for edit
      class Edit < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :default

        def run(sip_id:)
          sip = repository.find_sip(sip_id)
          form = repository.build_update_sip_form(sip: sip)
          authorization_layer.enforce!(submit?: form) do
            callback(:success, form)
          end
        end
      end

      # Responsible for creating and persisting a new Sip
      class Update < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :default

        def run(sip_id:, attributes:)
          sip = repository.find_sip(sip_id)
          form = repository.build_update_sip_form(sip: sip, attributes: attributes)
          authorization_layer.enforce!(submit?: form) do
            sip = repository.submit_update_sip_form(form, requested_by: current_user)
            if sip
              callback(:success, sip)
            else
              callback(:failure, form)
            end
          end
        end
      end
    end
  end
end
