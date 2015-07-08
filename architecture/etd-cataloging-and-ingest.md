# ETD Cataloging and Ingest Changes

What follows is a proposal for the changes to close out the cataloging and ingest workflow of ETDs.

## Workflow Entries

1. `(STATE(grad_school_changes_requested) || STATE(under_grad_school_review)) -> ACTION(send_to_cataloging) -> STATE(ready_for_cataloging)`
  - Available to `etd_reviewer`
2. `(STATE(grad_school_changes_requested) || STATE(under_grad_school_review)) -> ACTION(ingest_with_postponed_cataloging) -> STATE(ready_for_ingest)`
  - Available to `etd_reviewer`
  - Prompt the ETD Reviewer for a "Date to Notify Cataloging".
  - Capture this value in a new table; `Sipity::Models::Processing::AdministrativeScheduledAction` (see below)
3. `STATE(ready_for_ingest) -> ACTION(starting_ingest) -> STATE(ingest_started)`
  - For now, available to no one (this is an administrative thing)
4. `STATE(ingest_started) -> ACTION(finished_ingesting) -> STATE(ingest_complete)`
  - For now, available to no one (the ingester will take the action)
5. `STATE(ready_for_cataloging) -> ACTION(send_back_to_grad_school) -> STATE(back_from_cataloging)`
  - This action should prompt the cataloger for a comment
  - Available to `catalogers`
6. `STATE(back_from_cataloging) -> ACTION(send_to_cataloging) -> STATE(ready_for_cataloging)`
  - Available to `etd_reviewer`
7. `STATE(back_from_cataloging) -> ACTION(ingest_with_postponed_cataloging) -> STATE(ready_for_ingest)`
  - Available to `etd_reviewer`
  - Prompt the ETD Reviewer for a "Date to Notify Cataloging".
  - Capture this value in a new table; `Sipity::Models::Processing::AdministrativeSchedule` (see below)
8. `STATE(ready_for_cataloging)`: A cataloger must assign an OCLC number; This is a required TODO item for the given state.
  - Available to `cataloger`

The existing action `grad_school_signoff` will need to be removed from the ETD seeds, and deleted via a data_migration (`$ rails g data_migration`) (see https://github.com/jeremyf/data_migrator).

## Sipity::Models::Processing::AdministrativeScheduledAction

It should have the following column/attributes:

* **:scheduled_time** - The time in which we will do something
* **:reason** - The reason in which we are doing it; This should leverage the `ActiveRecord::Base.enum` method, with allowed values of `[:notify_cataloging]`
* **:entity** - A `belongs_to` relationship to `Sipity::Models::Processing::Entity`
  * Add the `has_many :administrative_scheduled_actions, dependent: :destroy` to `Sipity::Models::Processing::Entity`

Don't worry about how we will use this data, but instead focus on capturing the information.

## Data Migration

At present, when the Grad School is done with their review, they mark all entries as "Ready for Ingest". Any entries that have been marked as "Ready for Ingest" should be set to `back_from_cataloging`. This way the ETD Reviewers can determine whether to ingest or send to Cataloging.

## Roles

We will need to add the role `cataloger` to the list of valid role names.
