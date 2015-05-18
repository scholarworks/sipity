module Sipity
  module Forms
    module SubmissionWindows
      # Used for the basis of Submission Windows
      class BaseForm
        class_attribute :base_class, :policy_enforcer

        self.base_class = Models::SubmissionWindow
        self.policy_enforcer = Policies::SubmissionWindowPolicy

        class << self
          # Because ActiveModel::Validations is included at the class level,
          # and thus makes assumptions. Without `.model_name` method, the
          # validations choke.
          #
          # Do not delegate .name to the .base_class; Things will fall apart.
          #
          # @note This needs to be done after the ActiveModel::Validations,
          #   otherwise you will get the dreaded error:
          #
          #   ```console
          #   A copy of Sipity::Forms::SubmissionWindows::Ulra::StartASubmissionForm
          #   has been removed from the module tree but is still active!
          #   ```
          delegate :model_name, :human_attribute_name, to: :base_class
        end

        include ActiveModel::Validations
      end
    end
  end
end
