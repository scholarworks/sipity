module Sip
  module Decorators
    # A decoration layer for Sip::Collaborator
    class CollaboratorDecorator < Draper::Decorator
      def self.object_class
        Sip::Collaborator
      end

      delegate_all

      def possible_roles
        object.class.roles
      end

      def human_attribute_name(name)
        object.class.human_attribute_name(name)
      end

      def to_s
        name
      end
    end
  end
end
