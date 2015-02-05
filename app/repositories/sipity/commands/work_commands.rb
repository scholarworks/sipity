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
        # REVIEW: Should this be re-finding the work? Is it cheating to re-use
        #   the given work? Is it unsafe as far as state is concerned?
        entity.update(processing_state: to)
      end

      # TODO: Create a PidMinter service
      # REVIEW: Is this the correct location to put this behavior?
      def attach_file_to(work:, file:, user: user, pid_minter: pid_minter)
        pid = pid_minter.call
        Models::Attachment.create!(work: work, file: file, pid: pid, predicate_name: 'attachment')
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
      def pid_minter
        -> { Digest::UUID.uuid_v4 }
      end
    end
  end
end
