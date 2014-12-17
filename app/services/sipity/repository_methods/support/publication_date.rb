module Sipity
  module RepositoryMethods
    module Support
      # Responsible for managing Publication Date
      module PublicationDate
        module_function

        def create!(header:, publication_date:)
          return true unless publication_date.present?
          Support::AdditionalAttributes.update!(
            header: header, key: Models::AdditionalAttribute::PUBLICATION_DATE_PREDICATE_NAME, values: publication_date
          )
        end
      end
    end
  end
end
