module Sipity
  module Models
    module AuthenticationAgent
      # Responsible for negotiating the devise provided user and a Sipity agent.
      class FromDevise
        def initialize(user:, repository: default_repository)
          self.user = user
          self.repository = repository
          set_identifier_id!
        end

        def user_signed_in?
          true
        end

        def to_polymorphic_type
          'User'
        end
        delegate :id, :email, to: :user
        alias user_id id

        def name
          user.to_s
        end

        def agreed_to_application_terms_of_service?
          repository.agreed_to_application_terms_of_service?(identifier_id: identifier_id)
        end

        def ids
          [identifier_id, all_verified_netid_users_group_identifier_id]
        end

        def netid
          user.username
        end

        attr_reader :identifier_id
        alias to_identifier_id identifier_id

        private

        attr_accessor :user, :repository

        def all_verified_netid_users_group_identifier_id
          Cogitate::Client.encoded_identifier_for(strategy: 'group', identifying_value: Models::Group::ALL_VERIFIED_NETID_USERS)
        end

        def set_identifier_id!
          @identifier_id = Cogitate::Client.encoded_identifier_for(strategy: 'netid', identifying_value: netid)
        end

        def default_repository
          QueryRepository.new
        end
      end
    end
  end
end
