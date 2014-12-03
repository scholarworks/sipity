module Sip
  module Repo
    # Methods related to header creation
    module HeaderMethods
      BASE_HEADER_ATTRIBUTES = [:title, :work_publication_strategy].freeze
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

      def exposed_attribute_names_for(header:, additional_attribute_names: BASE_HEADER_ATTRIBUTES)
        (Support::AdditionalAttributes.keys_for(header: header) + additional_attribute_names).uniq
      end

      def submit_edit_header_form(form)
        form.submit do |f|
          Header.find(f.header.id) do |header|
            with_header_attributes_for_form(f) do |attributes|
              header.update(attributes)
            end
            with_each_additional_attribute_for_form(f) do |key, values|
              Support::AdditionalAttributes.update!(header: header, key: key, values: values)
            end
          end
        end
      end

      private

      def with_each_additional_attribute_for_form(form)
        Support::AdditionalAttributes.keys_for(header: form.header).each do |key|
          next unless  form.exposes?(key)
          yield(key, form.public_send(key))
        end
      end

      def with_header_attributes_for_form(form)
        attributes = {}
        BASE_HEADER_ATTRIBUTES.each do |attribute_name|
          attributes[attribute_name] = form.public_send(attribute_name) if form.exposes?(attribute_name)
        end
        yield(attributes) if attributes.any?
      end

      def existing_attributes_for(header)
        # TODO: How to account for additional fields and basic fields of header
        existing_attributes = { title: header.title, work_publication_strategy: header.work_publication_strategy }
        AdditionalAttribute.where(header: header).each_with_object(existing_attributes) do |attr, mem|
          # TODO: How to handle multi-value options
          mem[attr.key] = attr.value
        end
      end
    end
  end
end
