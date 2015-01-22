module Sipity
  module Models
    # Providing a "persistence" layer for various work types. This is the
    # canonical source for all work types.
    #
    # One reason for the class is that I want translations. This is something
    # that will be added later as it is not a primary concern.
    class WorkType
      NAMED_WORK_TYPES = [
        'etd'
      ].freeze

      def self.[](key)
        name = key.to_s.downcase
        if NAMED_WORK_TYPES.include?(name)
          new(name)
        else
          fail Exceptions::WorkTypeNotFoundError, name: name, container: 'WorkType::NAMED_WORK_TYPES'
        end
      end

      # Because the Work#work_type is being enforced via an enum; So I want the
      # Work object to not have to worry about translating the structure as it
      # has no knowledge of the underlying structure of the NAMED_WORK_TYPES
      def self.all_for_enum_configuration
        NAMED_WORK_TYPES.each_with_object({}) do |name, mem|
          mem[name] = name
          mem
        end
      end

      def initialize(name)
        @name = name
      end

      attr_reader :name
    end
  end
end
