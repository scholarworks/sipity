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

        def default_repository
          QueryRepository.new
        end
      end
    end
  end
end
