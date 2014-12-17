module Sipity
  # :nodoc:
  module RepositoryMethods
    # Citation related methods
    module AdditionalAttributeMethods
      def update_header_publication_date!(header:, publication_date:)
        return true unless publication_date.present?
        Support::AdditionalAttributes.update!(
          header: header, key: Models::AdditionalAttribute::PUBLICATION_DATE_PREDICATE_NAME, values: publication_date
        )
      end
      module_function :update_header_publication_date!
      public :update_header_publication_date!
    end
    private_constant :AdditionalAttributeMethods
  end
end
