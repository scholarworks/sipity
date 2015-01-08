# Permission Model (Draft v2)

**What follows is provisional, full of likely inaccuracies, but is meant as a guide post for understanding the authorization model.**

## Glossary

* Actor: A Group or User.
* Action: A thing that will/can be done to an object.
* AuthorizationLayer: The layer that asserts can a User perform the Action on the Entity.
* Entity: A permissionable entity.
* EntityType: The Rails base_class of an object; Needed for polymorphic relationships
* Group: A name for a group of users. Think in terms of nouns.
* Group Membership: Association of a user to a group.
* Permission: Intersection of an Entity, Actor, and Role
* Policy: Answers the question: Can the User take the given action on the given Entity.
* PolicyQuestion: A misnomer, perhaps better reflected as an action. See Action.
* Role: A name for a set of actions that can performed. Think in terms of verbs.
* Runner: Responsible for coordinating a User performing one or more Action/Entity pairs
* User: A person.
* WorkType: examples include ETD, SeniorThesis, Image; This is not the same as EntityType

## Concerns

There are two primary concerns in the Authorization subsystem.

* Granting permission
* Asserting permission

### Granting Permission

As Actions are taken on an Entity, Sipity grants the corresponding Permissions.
The Permissions granted are determined by:

* Querying the Role and Entity for the corresponding Actor(s) to assign
  - In the case of a SIP this means using its WorkType to query for the Actor
* Writing a Permission entry for the Actor,Role,Entity triple

### Asserting Permission

When a User attempts to take an Action on an Entity (via a Runner), the AuthorizationLayer:

* Finds the correct Policy for the given Entity.
* Asks the Policy object if the User can take the Action.
  * The Policy maps the Action to a Role (this could become more explicit)
  * This is done by querying to see if a Permission entry (i.e. Entity, Actor, Role) exists
* If no permission, then an exception is raised; Otherwise control passes back to the Runner

**Note: Role is to Action as Group is to User. It also means that actions and roles are being hard coded. I would like to reduce this to just actions. For now the system works.**
