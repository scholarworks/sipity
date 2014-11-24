module Sip
  # These are the service methods container. As I work on building the
  # more complicated data entry, I believe this will be required.
  class Repository
    def find_header(header_id, decorator: nil)
      header = Header.find(header_id)
      return header unless decorator.respond_to?(:decorate)
      decorator.decorate(header)
    end

    def build_header(decorator: nil, attributes: {})
      header = Header.new(attributes)
      return header unless decorator.respond_to?(:decorate)
      decorator.decorate(header)
    end

    def doi_request_is_pending?(_header)
      false
    end

    def doi_already_assigned?(header)
      header.additional_attributes.
        where(key: AdditionalAttribute::DOI_PREDICATE_NAME).count > 0
    end

    def build_header_doi_form(attributes = {})
      HeaderDoi.new(attributes)
    end

    def create_additional_attribute(header:, key:, value:)
      header.additional_attributes.create(key: key, value: value)
    end
  end
end
