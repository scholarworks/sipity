module Sipity
  class CommandRepositoryInterface
    # @see ./app/repositories/sipity/commands/work_commands.rb
    def attach_file_to(work:, file:, user: user, pid_minter: Services::PidMinter)
    end

    # @see ./app/repositories/sipity/commands/additional_attribute_commands.rb
    def create_work_attribute_values!(work:, key:, values:)
    end

    # @see ./app/repositories/sipity/commands/additional_attribute_commands.rb
    def destroy_work_attribute_values!(work:, key:, values:)
    end

    # @see ./app/repositories/sipity/commands/permission_commands.rb
    def grant_creating_user_permission_for!(entity:, user: nil, group: nil, actor: nil)
    end

    # @see ./app/repositories/sipity/commands/permission_commands.rb
    def grant_groups_permission_to_entity_for_acting_as!(entity:, acting_as:)
    end

    # @see ./app/repositories/sipity/commands/permission_commands.rb
    def grant_permission_for!(entity:, actors:, acting_as:)
    end

    # @see ./app/repositories/sipity/commands/transient_answer_commands.rb
    def handle_transient_access_rights_answer(entity:, answer:)
    end

    # @see ./app/repositories/sipity/commands/event_log_commands.rb
    def log_event!(entity:, user:, event_name:)
    end

    # @see ./app/repositories/sipity/commands/notification_commands.rb
    def send_notification_for_entity_trigger(notification:, entity:, acting_as:)
    end

    # @see ./app/repositories/sipity/commands/doi_commands.rb
    def submit_assign_a_doi_form(form, requested_by:)
    end

    # @see ./app/repositories/sipity/commands/account_placeholder_commands.rb
    def submit_create_orcid_account_placeholder_form(form, requested_by:)
    end

    # @see ./app/repositories/sipity/commands/doi_commands.rb
    def submit_doi_creation_request_job!(work:)
    end

    # @see ./app/repositories/sipity/commands/doi_commands.rb
    def submit_request_a_doi_form(form, requested_by:)
    end

    # @see ./app/repositories/sipity/commands/work_commands.rb
    def update_processing_state!(work:, new_processing_state:)
    end

    # @see ./app/repositories/sipity/commands/additional_attribute_commands.rb
    def update_work_attribute_values!(work:, key:, values:)
    end

    # @see ./app/repositories/sipity/commands/doi_commands.rb
    def update_work_doi_creation_request_state!(work:, state:, response_message: nil)
    end

    # @see ./app/repositories/sipity/commands/additional_attribute_commands.rb
    def update_work_publication_date!(work:, publication_date:)
    end

    # @see ./app/repositories/sipity/commands/doi_commands.rb
    def update_work_with_doi_predicate!(work:, values:)
    end

  end
end