# A Submission Information Package
# @see http://www.iasa-web.org/tc04/submission-information-package-sipity
module Sipity
  def self.table_name_prefix
    'sipity_'
  end

  module_function

  def t(*args)
    Controllers::TranslationAssistant.call(*args)
  end

  def support_statement_container_html(template:)
    support_statement_defaults = ['application.support_statement_container_html'.to_sym]
    # TODO: Should we make use of the Sipity.t method?
    if template.respond_to?(:view_object)
      begin
        work_area = PowerConverter.convert(template.send(:view_object), to: :work_area)
        support_statement_defaults.unshift("application.work_areas.#{work_area.slug}.support_statement_container_html".to_sym)
      rescue PowerConverter::ConversionError
        support_statement_defaults # No need to change the defaults
      end
    end
    I18n.t(support_statement_defaults.shift, default: support_statement_defaults, fallback: '').html_safe
  end
end

require File.expand_path('../sipity/models', __FILE__)
