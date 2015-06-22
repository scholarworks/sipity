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
end
