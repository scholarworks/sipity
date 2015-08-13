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

* Install a public key for the "base" Cogitate URL
* Switch authentication URL to `Cogitate.configuration.url_for_authentication`
* Incorporate session storage of JSON Web Token
  * What do we need to store in the user session? Identifiers? Emails?
