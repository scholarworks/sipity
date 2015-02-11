module Sipity
  # :nodoc:
  module Commands
    # Commands
    module WorkCommands
      # Responsible for assigning collaborators to a work.
      def assign_collaborators_to(work:, collaborators:)
        Array.wrap(collaborators).each do |collaborator|
          collaborator.work_id = work.id
          collaborators.save!
          next unless collaborator.responsible_for_review?
          create_sipity_user_from(netid: collaborator.netid) do |user|
            PermissionCommands.grant_permission_for!(actors: user, entity: work, acting_as: Models::Permission::ADVISOR)
          end
        end
      end

      def create_work!(attributes = {})
        Models::Work.create!(attributes.slice(:title, :work_publication_strategy, :work_type)) do |work|
          named_work_type = attributes.fetch(:work_type)
          work_type = Models::WorkType.find_or_create_by!(name: named_work_type)
          # A bit of a weirdness as I splice in the new behavior
          strategy = attributes.fetch(:processing_strategy) { work_type.find_or_initialize_default_processing_strategy.tap(&:save!) }
          strategy_state = attributes.fetch(:processing_strategy_state) { strategy.initial_strategy_state }
          work.build_processing_entity(strategy_state: strategy_state, strategy: strategy)
        end
      end

      def update_processing_state!(entity:, to:)
        update_deprecated_processing_state!(entity: entity, to: to)
        Services::UpdateEntityProcessingState.call(entity: entity, processing_state: to)
      end

      def update_deprecated_processing_state!(entity:, to:)
        entity.update(processing_state: to)
      end
      deprecate :update_deprecated_processing_state!
      private :update_deprecated_processing_state!

      def attach_file_to(work:, file:, user:, pid_minter: default_pid_minter)
        # I know I want the user, but I'm not certain what we are doing with it
        # just yet.
        _user = user
        pid = pid_minter.call
        Models::Attachment.create!(work: work, file: file, pid: pid, predicate_name: 'attachment')
      end

      def remove_files_from(pid:, user: user)
        Models::Attachment.where(pid: pid).destroy_all
      end

      def mark_as_representative(work:, pid:, user: user)
        attachment = Models::Attachment.find_by(pid: pid)
        return true unless attachment.present?
        Models::Attachment.where(work_id: work.id, is_representative_file: true).update_all(is_representative_file: false)
        attachment.update(is_representative_file: true)
      end

      def create_sipity_user_from(netid:)
        return false unless netid.present?
        # This assumes a valid NetID.
        user = User.find_or_create_by!(username: netid)
        yield(user) if block_given?
        user
      end

      # @return [#call] A call-able object that when called will return a String
      #
      # @note This is not a PID as per Fedora 3, but is something random,
      #   unique, and stringy. Which for these purposes is adequate.
      def default_pid_minter
        -> { SecureRandom.urlsafe_base64(nil, true) }
      end
    end
  end
end
