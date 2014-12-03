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

      def submit_create_header_form(form)
        form.submit do |f|
          Header.create!(title: f.title, work_publication_strategy: f.work_publication_strategy) do |header|
            Support::Collaborators.create!(header: header, collaborators: f.collaborators)
            Support::PublicationDate.create!(header: header, publication_date: f.publication_date)
          end
        end
      end

      def build_edit_header_form(header:, attributes: {})
        fail "Expected #{header} to be persisted" unless header.persisted?
        exposed_attribute_names = exposed_attribute_names_for(header: header)
        EditHeaderForm.new(header: header, exposed_attribute_names: exposed_attribute_names, attributes: attributes)
      end

      def exposed_attribute_names_for(header:, additional_attribute_names: [:title, :collaborators_attributes])
        keys = AdditionalAttribute.where(header: header).pluck(:key).uniq
        keys + additional_attribute_names
      end

      def submit_edit_header_form(form)
        form.submit do |f|
          Header.find(f.header.id) do |header|
            header.update(title: f.title) if f.exposes?(:title)
          end
        end
      end
    end
  end
end
