module Sipity
  module ResponseHandlers
    # This is an Experimental module and concept
    module SubmissionWindowHandler
      # Responsible for handling a :success-ful action
      #
      # TODO: Extract a porper base class, if one exists
      class SuccessResponse < ResponseHandlers::WorkAreaHandler::SuccessResponse
      end
    end
  end
end
