module Sipity
  # :nodoc:
  module Mailers
    # This class is responsible for creating/delivering emails associated with
    # the ULRA work area.
    LibraryProjectMailer = MailerBuilder.build('library_project') do
      email(name: :confirmation_of_project_proposal_created, as: :work)
      email(name: :confirmation_of_project_proposal_submitted, as: :work)
      email(name: :project_proposal_accepted, as: :work)
      email(name: :project_proposal_rejected, as: :work)
      email(name: :project_proposal_submitted_to_directors, as: :work)
      email(name: :project_proposal_submitted_to_pmos, as: :work)
    end
  end
end
