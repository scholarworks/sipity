module Sipity
  module Models
    module AuthenticationAgent
      # Responsible for converting a cogitate agent into a Sipity agent
      class FromCogitate
        def initialize(cogitate_agent:, ids_decoder: default_ids_decoder, repository: default_repository)
          self.cogitate_agent = cogitate_agent
          self.ids_decoder = ids_decoder
          self.repository = repository
        end

        def email
          cogitate_agent.with_emails.to_a.first
        end

        def user_signed_in?
          true
        end

        # A hack for Devise and actor conversions
        def netid
          return @netid if @netid
          ids.each do |id|
            ids_decoder.call(id).each do |identifier|
              next unless identifier.strategy == 'netid'
              @netid = identifier.identifying_value
            end
            break if @netid
          end
          @netid
        end

        def agreed_to_application_terms_of_service?
          repository.agreed_to_application_terms_of_service?(identifier_id: identifier_id)
        end

        delegate :ids, :name, to: :cogitate_agent

        def identifier_id
          Cogitate::Client.encoded_identifier_for(strategy: 'netid', identifying_value: netid)
        end

        alias to_identifier_id identifier_id

        private

        attr_accessor :cogitate_agent, :ids_decoder, :repository

        def default_ids_decoder
          require 'cogitate/services/identifiers_decoder' unless defined?(Cogitate::Services::IdentifiersDecoder)
          Cogitate::Services::IdentifiersDecoder
        end

        def default_repository
          QueryRepository.new
        end
      end
    end
  end
end
