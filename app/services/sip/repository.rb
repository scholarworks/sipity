module Sip
  # These are the service methods container. As I work on building the
  # more complicated data entry, I believe this will be required.
  class Repository
    include Sip::Repo::HeaderMethods

    def citation_already_assigned?(header)
      header.additional_attributes.
        where(key: AdditionalAttribute::CITATION_PREDICATE_NAME).count > 0
    end

    def doi_request_is_pending?(header)
      # TODO: This is not the final answer to this question.
      # There is an underlying state machine implied.
      !header.doi_creation_request.nil?
    end

    def doi_already_assigned?(header)
      header.additional_attributes.
        where(key: AdditionalAttribute::DOI_PREDICATE_NAME).count > 0
    end

    def build_assign_a_citation_form(attributes = {})
      AssignACitationForm.new(attributes)
    end

    def submit_assign_a_citation_form(form)
      form.submit do |f|
        create_additional_attribute(header: f.header, key: AdditionalAttribute::CITATION_PREDICATE_NAME, value: f.citation)
        create_additional_attribute(header: f.header, key: AdditionalAttribute::CITATION_TYPE_PREDICATE_NAME, value: f.type)
      end
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

    def submit_request_a_doi_form(form)
      form.submit do |f|
        create_additional_attribute(header: f.header, key: AdditionalAttribute::PUBLISHER_PREDICATE_NAME, value: f.publisher)
        assign_publication_date_to_header(header: f.header, publication_date: f.publication_date)
        create_doi_creation_request(header: f.header)
      end
    end

    private

    def create_header!(attributes = {})
      header = Header.create!(attributes)
      yield(header)
      header
    end

    def assign_collaborators_to_header(header:, collaborators:)
      collaborators.each do |collaborator|
        collaborator.header = header
        collaborator.save!
      end
    end

    def assign_publication_date_to_header(header:, publication_date:)
      return true if publication_date.blank?
      create_additional_attribute(header: header, key: AdditionalAttribute::PUBLICATION_DATE_PREDICATE_NAME, value: publication_date)
    end

    def create_additional_attribute(header:, key:, value:)
      header.additional_attributes.create!(key: key, value: value)
    end

    def create_doi_creation_request(header:)
      # TODO: Remove magic string
      header.create_doi_creation_request!(state: 'request_not_yet_submitted')
    end
  end
end
