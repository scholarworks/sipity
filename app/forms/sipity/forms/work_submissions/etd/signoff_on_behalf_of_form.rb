module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        # Responsible for exposing ability for someone to signoff on the work
        # on behalf of someone else.
        class SignoffOnBehalfOfForm
          ProcessingForm.configure(form_class: self, base_class: Models::Work, attribute_names: [:on_behalf_of_collaborator_id])

          def initialize(work:, attributes: {}, signoff_service: default_signoff_service, **keywords)
            self.work = work
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.on_behalf_of_collaborator_extension = build_collaborator_extension
            self.on_behalf_of_collaborator_id = attributes[:on_behalf_of_collaborator_id]
            self.signoff_service = signoff_service
          end

          include ActiveModel::Validations
          validates :on_behalf_of_collaborator_id, presence: true, inclusion: { in: :valid_on_behalf_of_collaborator_ids }

          delegate(
            :valid_on_behalf_of_collaborators,
            :on_behalf_of_collaborator,
            :on_behalf_of_collaborator_id,
            :on_behalf_of_collaborator_id=,
            :valid_on_behalf_of_collaborator_ids,
            to: :on_behalf_of_collaborator_extension
          )

          private(:on_behalf_of_collaborator_id=)

          def render(f:)
            f.input(:on_behalf_of_collaborator_id, collection: valid_on_behalf_of_collaborators, value_method: :id)
          end

          # Expose that information in the database; Determine how this relates
          # to the Sipity::Models::Processing::StrategyActionAnalogue.
          RELATED_ACTION_FOR_SIGNOFF = 'advisor_signoff'.freeze
          def submit(requested_by:)
            return false unless valid?
            signoff_service.call(
              form: self,
              requested_by: requested_by,
              repository: repository,
              on_behalf_of: on_behalf_of_collaborator,
              also_register_as: RELATED_ACTION_FOR_SIGNOFF
            )
            work
          end

          private

          attr_accessor :on_behalf_of_collaborator_extension, :signoff_service

          def default_signoff_service
            Services::AdvisorSignsOff
          end

          def build_collaborator_extension
            Forms::ComposableElements::OnBehalfOfCollaborator.new(form: self, repository: repository)
          end
        end
      end
    end
  end
end
