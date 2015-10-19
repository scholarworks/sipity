require 'cogitate/models/agent'
module Sipity
  module Conversions
    # @see Sipity::Conversions for conventions regarding a conversion method
    module ConvertToProcessingActor
      def self.call(input)
        convert_to_processing_actor(input)
      end

      def convert_to_processing_actor(input)
        return input if input.is_a?(Models::Processing::Actor)
        return input.to_processing_actor if input.respond_to?(:to_processing_actor)
        case input
        when User, Models::Group then
          # I'm opting to use input.id.present? instead of persisted? as I'm
          # thinking that I would prefer the option of tests not quite building
          # up the whole world.
          return Models::Processing::Actor.find_or_create_by!(proxy_for: input) if input.id.present?
        when Sipity::Models::Agent::FromCogitate, Sipity::Models::Agent::FromDevise then
          user = User.where(username: input.netid).first
          return convert_to_processing_actor(user) if user
        end
        fail Exceptions::ProcessingActorConversionError, input
      end

      module_function :convert_to_processing_actor
      private_class_method :convert_to_processing_actor
      private :convert_to_processing_actor
    end
  end
end
