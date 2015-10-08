module Sipity
  module Models
    module AuthenticationAgent
      # We have an anonymous visitor accessing the website
      class NullAgent
        def name
          'anonymous'
        end

        def email
          ''
        end

        def ids
          []
        end

        def signed_in?
          false
        end

        def agreed_to_application_terms_of_service?
          false
        end
      end
    end
  end
end
