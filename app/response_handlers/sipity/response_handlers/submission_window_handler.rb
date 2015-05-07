module Sipity
  module ResponseHandlers
    # This is an Experimental module and concept
    module SubmissionWindowHandler
      # Responsible for handling a :success-ful action
      #
      # TODO: Extract a proper base class, if one exists
      #
      # :Success
      # :Submitted
      # :FailedToSubmit
      class SuccessResponse < ResponseHandlers::WorkAreaHandler::SuccessResponse
      end

      # TODO: This should do something
      class FailureResponse < SuccessResponse
      end
    end
  end
end
