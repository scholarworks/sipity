module Sipity
  module StateMachines
    # Responsible for answering questions related to a StateDiagram. This is
    # something that a DSL might be helpful for generating.
    #
    # @see the corresponding tests on what is a well-formed datastructure.
    class StateDiagram
      def initialize(data_structure)
        @data_structure = data_structure
        validate!
        @data_structure.freeze
      end
      attr_reader :data_structure
      private :data_structure

      # REVIEW: This is really complicated
      def available_events_for_when_acting_as(current_state:, acting_as:)
        events_and_acting_as_for(current_state).each_with_object(Set.new) do |(event_name, possible_acting_as), mem|
          to_keep = (Array.wrap(possible_acting_as) & Array.wrap(acting_as))
          if to_keep.present?
            # Normalizing event name
            mem << ActionAvailability.new(event_name, to_keep, current_state)
          end
          mem
        end.map(&:event_name)
      end

      def available_event_triggers(current_state:)
        events_and_acting_as_for(current_state).each_with_object(Set.new) do |(event_name, acting_as), mem|
          mem << ActionAvailability.new(event_name, acting_as, current_state)
          mem
        end.to_a
      end

      def event_trigger_availability(current_state:, event_name:)
        normalized_event_name = event_name.to_s.sub(/([^\?])\Z/, '\1?').to_sym
        acting_as = events_and_acting_as_for(current_state).fetch(normalized_event_name, [])
        ActionAvailability.new(event_name, acting_as, current_state)
      end

      private

      def events_and_acting_as_for(current_state)
        data_structure.fetch(current_state.to_s, {})
      end

      # Crafting a welformed object
      ActionAvailability = Struct.new(:event_name, :acting_as, :current_state) do
        def initialize(event_name, acting_as, current_state)
          modified_event_name = event_name.to_s.sub(/\?\Z/, '')
          modified_acting_as = Array.wrap(acting_as)
          super(modified_event_name, modified_acting_as, current_state.to_s)
        end
      end
      private_constant :ActionAvailability

      def validate!
        # TODO: This could be tidied up by building a Hash with indifferent access.
        no_errors = true
        data_structure.each_pair do |state, hash|
          if state.is_a?(String)
            if state =~ /\?\Z/
              no_errors = false
              break
            end
          else
            no_errors = false
            break
          end
          hash.each_pair do |event_name, acting_as|
            if event_name.is_a?(Symbol)
              if event_name.to_s !~ /\?\Z/
                no_errors = false
                break
              end
            else
              no_errors = false
              break
            end
            Array.wrap(acting_as).each do |item|
              unless item.is_a?(String)
                no_errors = false
                break
              end
            end
          end
        end
        return true if no_errors
        fail Exceptions::InvalidStateDiagramRawStructure, structure: data_structure
      rescue NoMethodError
        raise Exceptions::InvalidStateDiagramRawStructure, structure: data_structure
      end
    end
  end
end
