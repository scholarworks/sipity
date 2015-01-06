module Sipity
  module Mailers
    # This class is responsible for creating/delivering email
    #
    class EmailNotifier < ActionMailer::Base
      default from: 'curate@nd.edu', return_path: 'no-reply@nd.edu'
      layout 'mailer'

      def confirmation_of_entity_submitted_for_review(entity:, to:, cc: [], bcc: [])
        @entity = entity
        mail(to: to, cc: cc, bcc: bcc)
      end
    end
  end
end
