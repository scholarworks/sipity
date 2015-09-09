module Sipity
  module Services
    module Queries
      # Responsible for exposing the a given entity's agent permissions via aggregation of
      # the local role and expanded identifier_id.
      class AgentsAssociatedWithEntity
        def initialize(entity:, **keywords)
          self.entity = entity
          self.role_and_identifier_ids_finder = keywords.fetch(:role_and_identifier_ids_finder) { default_role_and_identifier_ids_finder }
          self.agents_finder = keywords.fetch(:agents_finder) { default_agents_finder }
          self.aggregator = keywords.fetch(:aggregator) { default_aggregator }
        end

        def each
          return enum_for(:each) unless block_given?
          aggregated_data.each { |datum| yield(datum) }
        end

        private

        def aggregated_data
          role_and_identifier_ids = find_all_roles_and_associated_identifiers
          agents = agents_finder.call(identifier_ids: role_and_identifier_ids.map(&:identifier_id))
          aggregator.call(role_and_identifier_ids: role_and_identifier_ids, agents: agents)
        end

        attr_reader :entity
        def entity=(input)
          @entity = Conversions::ConvertToProcessingEntity.call(input)
        end

        def find_all_roles_and_associated_identifiers
          role_and_identifier_ids_finder.call(entity: entity)
        end

        attr_accessor :role_and_identifier_ids_finder
        def default_role_and_identifier_ids_finder
          RoleIdentifierFinder.method(:all_for)
        end

        attr_accessor :agents_finder
        def default_agents_finder
          AgentsFinder.method(:find)
        end

        attr_accessor :aggregator
        def default_aggregator
          Aggregator.method(:aggregate)
        end

        # :nodoc:
        module RoleIdentifierFinder
          def self.all_for(*)
          end
        end
        private_constant :RoleIdentifierFinder

        # :nodoc:
        module AgentsFinder
          def self.find(*)
          end
        end
        private_constant :AgentsFinder

        # :nodoc:
        module Aggregator
          def self.aggregate(*)
          end
        end
        private_constant :Aggregator
      end
    end
  end
end
