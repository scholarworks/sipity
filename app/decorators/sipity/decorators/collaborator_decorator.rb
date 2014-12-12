module Sipity
  module Decorators
    # A decoration layer for Sipity::Collaborator
    class CollaboratorDecorator < Draper::Decorator
      def self.object_class
        Models::Collaborator
      end

      delegate_all

      def human_attribute_name(name)
        object.class.human_attribute_name(name)
      end

      def to_s
        name
      end
    end
  end
end
