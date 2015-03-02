module Sipity
  module Decorators
    module Emails
      class AdvisorRequestsChangeDecorator
        def initialize(processing_comment)
          @processing_comment = processing_comment
        end

        def name_of_commentor
        end

        def document_type
        end

        delegate :comment, to: :@processing_comment
      end
    end
  end
end
