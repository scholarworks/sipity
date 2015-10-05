module Sipity
  module Models
    module Agent
      # Sipity may have an identifier that does not exist in Cogitate (i.e. an Email of a Collaborator)
      # This object provides a means of exposing an Agent that is a bit more contrived.
      class FromIdentifierId
        def initialize(identifier_id:, attributes: {})
          self.identifier_id = identifier_id
          self.attributes = attributes
          extract_strategy_and_identifying_value!
        end

        def name
          attributes['name'] || attributes['display_name'] || identifying_value
        end

        def email
          attributes['email'] || nil
        end

        def ids
          [identifier_id]
        end

        def user_signed_in?
          false
        end

        def agreed_to_application_terms_of_service?
          false
        end

        attr_reader :strategy, :identifying_value, :identifier_id

        private

        def method_missing(method_name, *args, &block)
          attributes.fetch(method_name.to_s) { super }
        end

        def respond_to_missing?(method_name, *args)
          attributes.key?(method_name.to_s) || super
        end

        attr_writer :identifier_id
        attr_reader :attributes

        def attributes=(input)
          @attributes = input.each_with_object({}) do |(key, value), mem|
            mem[key.to_s] = value
            mem
          end
        end

        def extract_strategy_and_identifying_value!
          @strategy, @identifying_value = Cogitate::Client.extract_strategy_and_identifying_value(identifier_id)
        end
      end
    end
  end
end
