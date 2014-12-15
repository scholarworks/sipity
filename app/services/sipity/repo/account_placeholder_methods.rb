module Sipity
  module Repo
    module AccountPlaceholderMethods
      def build_create_orcid_account_placeholder_form(attributes: {})
        Forms::CreateOrcidAccountPlaceholderForm.new(attributes)
      end

      def submit_create_orcid_account_placeholder_form(form, requested_by:)
        form.submit do |f|
          true
        end
      end
    end
  end
end
