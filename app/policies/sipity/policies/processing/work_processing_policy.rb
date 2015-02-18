module Sipity
  module Policies
    module Processing
      # Responsible for enforcing access to the processing of a given Sipity::Work
      #
      # This class answers can I take the given action based on the user and
      # the work.
      #
      # @see [Pundit gem](http://rubygems.org/gems/pundit) for more on object
      #   oriented authorizaiton.
      #
      # @note This class implements method_missing in an attempt to splice in
      #   this policy into Sipity's interactions.
      class WorkProcessingPolicy
        def initialize(user, work, repository: default_repository)
          @user = user
          @work = work
          @repository = repository
        end

        attr_reader :user, :work

        def authorize?(action)
          repository.authorized_for_processing?(user: user, entity: work, action: action)
        end

        attr_reader :repository
        private :repository

        private

        # Means of preserving interface defined by Sipity::Policies::WorkPolicy
        def method_missing(method_name, *)
          authorize?(method_name)
        end

        def default_repository
          QueryRepository.new
        end
      end
    end
  end
end
