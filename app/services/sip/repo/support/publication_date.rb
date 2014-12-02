module Sip
  module Repo
    module Support
      # Responsible for managing Publication Date
      module PublicationDate
        module_function

        def create!(header:, publication_date:)
          return true unless publication_date.present?
          AdditionalAttribute.create!(
            header: header, key: AdditionalAttribute::PUBLICATION_DATE_PREDICATE_NAME, value: publication_date
          )
        end
      end
    end
  end
end
