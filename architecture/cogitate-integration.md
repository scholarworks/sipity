# Cogitate Integration

*What follows are incomplete thoughts and a scratch pad for migration thoughts.*

[Cogitate](https://github.com/ndlib/cogitate) is a federated identity management system for managing user identities and communication channels.

The goal is to replace identity related information with using the Cogitate service.

## Considerations

* Drop tables and corresponding models
  * `users` (model `User`)
  * `sipity_groups` (model `Sipity::Models::Group`)
  * `sipity_group_memberships` (model `Sipity::Models::GroupMembership`)
* Rework queries that retrieve emails for given role(s)
  * This may need a custom API end-point on Cogitate
* Migrate `Sipity::Models::Processing::Actor#proxy_for` relationship to a Cogitate identifier with corresponding data structure changes
* Migrate existing User, Group, and GroupMembership to Cogitate data structure
  * **Review:** Should this be done via an API service point? No need because we thusfar control the groups.
* Need a quick Cogitate mock object

## Migration Plan

Below is a sequence of steps to take. It should not be considered final.
**NOTE:** These have been posted as issues on Sipity's issue tracker for the [Cogitate Milestone](https://github.com/ndlib/sipity/milestones/Cogitate%20Integration).

1. ~~Install local reference to Cogitate for development~~
1. ~~Configure Cogitate~~
1. Create Cogitate mock user scenarios for testing
  * Verified user and groups
  * Unverified user and groups
1. Rework user authentication to leverage Cogitate's JWT authentication
  1. Add `Sipity::Controllers::SessionController#new`
    * This action redirects to Cogitate
  1. Add `Sipity::Controllers::SessionController#create`
    * This action receive's Cogitate's response and sets the session information
  1. Adjust `current_user` to find the user in the current `users` table based on the Cogitate::AuthenticatedToken.
  1. Remove Devise usage!!!
1. Move email processing to Asynchronous
  * With querying email addresses against a remote API, I don't want to lock the request loop.
1. Deploy Cogitate to Staging, PreProduction, Production environment
1. Migrate `Sipity::Models::Processing::Actor#proxy_for` to Cogitate key structure
  1. Convert Sipity groups to Cogitate groups
