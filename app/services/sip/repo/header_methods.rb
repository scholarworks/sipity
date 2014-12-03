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
        new_attributes = existing_attributes_for(header).merge(attributes)
        exposed_attribute_names = exposed_attribute_names_for(header: header)
        EditHeaderForm.new(header: header, exposed_attribute_names: exposed_attribute_names, attributes: new_attributes)
      end

      def exposed_attribute_names_for(header:, additional_attribute_names: nil)
        # TODO: What's with the magic array?
        (
          AdditionalAttribute.where(header: header).pluck(:key) +
          (
            additional_attribute_names ||
            [:title, :collaborators_attributes, :publication_date, :work_publication_strategy]
          )
        ).uniq
      end

      def submit_edit_header_form(form)
        form.submit do |f|
          Header.find(f.header.id) do |header|
            header.update(title: f.title) if f.exposes?(:title)
          end
        end
      end

      private

      def existing_attributes_for(header)
        # TODO: How to account for additional fields and basic fields of header
        existing_attributes = { title: header.title, work_publication_strategy: header.work_publication_strategy }
        AdditionalAttribute.where(header: header).each_with_object(existing_attributes) do |attr, mem|
          mem[attr.key] = attr.value
        end
      end
    end
  end
end
