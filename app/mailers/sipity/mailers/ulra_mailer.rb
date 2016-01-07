module Sipity
  # :nodoc:
  module Mailers
    # This class is responsible for creating/delivering emails associated with
    # the ULRA work area.
    UlraMailer = MailerBuilder.build('ulra') do
      email(name: :confirmation_of_submitted_to_ulra_committee, as: :work)
      email(name: :confirmation_of_ulra_submission_started, as: :work)
      email(name: :faculty_assigned_for_ulra_submission, as: :work)
      email(name: :faculty_completed_their_portion_of_ulra, as: :work)
      email(name: :student_completed_their_portion_of_ulra, as: :work)
      email(name: :student_has_indicated_attachments_are_complete, as: :work)
    end
  end
end
