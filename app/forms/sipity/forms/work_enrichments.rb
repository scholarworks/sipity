# Because of the `const_defined?` I'm requiring the various sipity work
# enrichment forms.
Dir[File.expand_path('../work_enrichments/*.rb', __FILE__)].each do |filename|
  require_relative "./work_enrichments/#{File.basename(filename)}"
end

module Sipity
  module Forms
    # A container for the various WorkEnrichment forms
    module WorkEnrichments
      module_function

      def find_enrichment_form_builder(enrichment_type:)
        form_name_by_convention = "#{enrichment_type.classify}Form"
        "#{self}::#{form_name_by_convention}".constantize
      rescue NameError
        raise Exceptions::EnrichmentNotFoundError, name: form_name_by_convention, container: self
      end
    end
  end
end
