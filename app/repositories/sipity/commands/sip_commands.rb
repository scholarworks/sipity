module Sipity
  # :nodoc:
  module Commands
    # Commands
    module SipCommands
      extend ActiveSupport::Concern
      included do |base|
        base.send(:include, Queries::SipQueries)
      end
      # TODO: This is duplicationed
      BASE_HEADER_ATTRIBUTES = [:title, :work_publication_strategy].freeze
      def update_processing_state!(sip:, new_processing_state:)
        # REVIEW: Should this be re-finding the sip? Is it cheating to re-use
        #   the given sip? Is it unsafe as far as state is concerned?
        sip.update(processing_state: new_processing_state)
      end

      def submit_create_sip_form(form, requested_by:)
        form.submit do |f|
          sip = Models::Sip.create!(title: f.title, work_publication_strategy: f.work_publication_strategy)
          # TODO: Extract the method call below to a Repository command, because
          #   what happens based on answer could be very complicated.
          Models::TransientAnswer.create!(
            entity: sip, question_code: Models::TransientAnswer::ACCESS_RIGHTS_QUESTION, answer_code: f.access_rights_answer
          )
          AdditionalAttributeCommands.update_sip_publication_date!(sip: sip, publication_date: f.publication_date)
          PermissionCommands.grant_creating_user_permission_for!(entity: sip, user: requested_by)
          EventLogCommands.log_event!(entity: sip, user: requested_by, event_name: __method__)
          sip
        end
      end

      def submit_update_sip_form(form, requested_by:)
        form.submit do |f|
          sip = find_sip(f.sip.id)
          with_sip_attributes_for_form(f) { |attributes| sip.update(attributes) }
          with_each_additional_attribute_for_sip_form(f) do |key, values|
            AdditionalAttributeCommands.update_sip_attribute_values!(sip: sip, key: key, values: values)
          end
          EventLogCommands.log_event!(entity: sip, user: requested_by, event_name: __method__) if requested_by
          sip
        end
      end

      private

      def with_each_additional_attribute_for_sip_form(form)
        Queries::AdditionalAttributeQueries.sip_attribute_keys_for(sip: form.sip).each do |key|
          next unless  form.exposes?(key)
          yield(key, form.public_send(key))
        end
      end

      def with_sip_attributes_for_form(form)
        attributes = {}
        BASE_HEADER_ATTRIBUTES.each do |attribute_name|
          attributes[attribute_name] = form.public_send(attribute_name) if form.exposes?(attribute_name)
        end
        yield(attributes) if attributes.any?
      end
    end
    private_constant :SipCommands
  end
end
