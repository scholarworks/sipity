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
            assign_publication_date_to_header(header: header, publication_date: f.publication_date)
          end
        end
      end
    end
  end
end
