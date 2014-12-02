module Sip
  module Repo
    # Methods related to header creation
    module HeaderMethods
      def find_header(header_id, decorator: nil)
        header = Header.find(header_id)
        return header unless decorator.respond_to?(:decorate)
        decorator.decorate(header)
      end

      def build_create_header_form(decorator: nil, attributes: {})
        header = CreateHeaderForm.new(attributes)
        return header unless decorator.respond_to?(:decorate)
        decorator.decorate(header)
      end
      alias_method :build_header, :build_create_header_form

      def submit_create_header_form(form)
        form.submit do |f|
          create_header!(title: f.title, work_publication_strategy: f.work_publication_strategy) do |header|
            assign_collaborators_to_header(collaborators: f.collaborators, header: header)
            if f.publication_date.present?
              AdditionalAttribute.create!(
                header: header, key: AdditionalAttribute::PUBLICATION_DATE_PREDICATE_NAME, value: f.publication_date
              )
            end
          end
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
    end
  end
end
