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

    def build_assign_a_doi_form(attributes = {})
      AssignADoiForm.new(attributes)
    end

    def submit_assign_a_doi_form(form)
      form.submit do |f|
        create_additional_attribute(header: f.header, key: f.identifier_key, value: f.identifier)
      end
    end

    def build_request_a_doi_form(attributes = {})
      RequestADoiForm.new(attributes)
    end

    private

    def create_additional_attribute(header:, key:, value:)
      header.additional_attributes.create(key: key, value: value)
    end
  end
end
