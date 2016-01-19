require 'active_support/core_ext/array/wrap'

module Sipity
  # :nodoc:
  module Commands
    # Commands
    module WorkCommands
      # Responsible for adding collaborators to the work and removing anyone
      # else.
      def manage_collaborators_for(work:, collaborators:, repository: self)
        collaborators_table = Models::Collaborator.arel_table
        Models::Collaborator.where(
          collaborators_table[:work_id].eq(work.id).and(
            collaborators_table[:id].not_in(Array.wrap(collaborators).flat_map(&:id))
          )
        ).destroy_all

        assign_collaborators_to(work: work, collaborators: collaborators, repository: repository)
      end

      # Responsible for assigning collaborators to a work.
      def assign_collaborators_to(work:, collaborators:, repository: self)
        # TODO: Encapsulate this is a Service Object as there is enough logic
        # to warrant this behavior.
        Array.wrap(collaborators).each do |collaborator|
          collaborator.work_id = work.id
          collaborator.save!
          next unless collaborator.responsible_for_review?
          create_sipity_user_from(netid: collaborator.netid, email: collaborator.email) do |user|
            change_processing_actor_proxy(from_proxy: collaborator, to_proxy: user)
            # TODO: This cannot be the assumed role for the :acting_as; I wonder if it would make sense
            # to dilineate roles on the contributor and roles in the system?
            repository.grant_permission_for!(actors: user, entity: work, acting_as: Models::Role::ADVISING)
          end
        end
      end

      # In an effort to preserve processing actors, I want to expose a mechanism
      # for transfering processing actors to another proxy.
      #
      # This method arises as we consider the scenario in which someone approves
      # on behalf of a non-User collaborator (i.e. someone that has an email
      # address). Then the collaborator is changed such that a user is created.
      def change_processing_actor_proxy(from_proxy:, to_proxy:)
        return unless from_proxy.respond_to?(:processing_actor) && from_proxy.processing_actor.present?
        from_proxy.processing_actor.update(proxy_for: to_proxy)
      end

      def create_work!(submission_window:, **attributes)
        Services::CreateWorkService.call(submission_window: submission_window, repository: self, **attributes)
      end

      def update_work_title!(work:, title:)
        work.update!(title: title)
      end

      # This may look ridiculous, but I'd like to isolate the destruction so
      # that I can associate any other actions with it (i.e. logging, emails, etc.)
      def destroy_a_work(work:)
        work.destroy
      end

      def update_processing_state!(entity:, to:)
        Services::UpdateEntityProcessingState.call(entity: entity, processing_state: to, repository: self)
      end

      def attach_files_to(work:, files:, predicate_name: 'attachment', **keywords)
        # I know I want the user, but I'm not certain what we are doing with it
        # just yet.
        pid_minter = keywords.fetch(:pid_minter) { default_pid_minter }
        Array.wrap(files).each do |file|
          next unless file.present? # because we may have gotten [{}]
          pid = pid_minter.call
          Models::Attachment.create!(work: work, file: file, pid: pid, predicate_name: predicate_name)
        end
      end

      def remove_files_from(work:, user:, pids:, predicate_name: 'attachment')
        _user = user # Don't need it yet, but it makes sense to capture this
        Models::Attachment.where(work: work, pid: Array.wrap(pids), predicate_name: predicate_name).destroy_all
      end

      def amend_files_metadata(work:, user:, metadata: {})
        _user = user
        metadata.each do |pid, data|
          Models::Attachment.where(work: work).find(pid).
            update_attributes!(data.with_indifferent_access.slice(:name))
        end
      end

      def set_as_representative_attachment(work:, pid:)
        attachment = Models::Attachment.find_by(work_id: work.id, pid: pid)
        return true unless attachment.present?
        Models::Attachment.where(work_id: work.id, is_representative_file: true).where.not(pid: attachment.pid).
          update_all(is_representative_file: false)
        Models::Attachment.where(work_id: work.id, pid: attachment.pid).update_all(is_representative_file: true)
      end

      def create_sipity_user_from(netid:, email: nil)
        return false unless netid.present?
        # This assumes a valid NetID.
        user = User.find_or_create_by!(username: netid) do |u|
          u.email = email || default_email_for_netid(netid)
        end
        yield(user) if block_given?
        user
      end

      def default_email_for_netid(netid)
        "#{netid}@nd.edu"
      end
      private :default_email_for_netid

      # @return [#call] A call-able object that when called will return a String
      #
      # @note This is not a PID as per Fedora 3, but is something random,
      #   unique, and stringy. Which for these purposes is adequate.
      def default_pid_minter
        Rails.application.config.default_pid_minter
      end

      def apply_access_policies_to(work:, user:, access_policies:)
        Services::ApplyAccessPoliciesTo.call(work: work, user: user, access_policies: access_policies)
      end
    end
  end
end
