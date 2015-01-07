# Permission Model (Draft v1)

**What follows is provisional, full of likely inaccuracies, but is meant as a guide post for understanding the authorization model.**

## Glossary

* Actor: A Group or User.
* Entity: A permissionable entity.
* Group: A name for a group of users. Think in terms of nouns.
* Group Membership: Association of a user to a group.
* Permission: Intersection of an Entity, Actor, and Role
* Policy: Answers the question: Can the User take the given action on the given Entity.
* Role: A name for a set of responsibilities. Think in terms of verbs.
* User: A person.

### Example:

Assume the following:

* Alice is a User
* Cataloging is a Role
* Catalogers is a Group
* Alice is a member of the Catalogers group
* BigBadBook is an Entity
* BigBadBook has a permission entry for Cataloging (role) and Catalogers (group)

**Note: The above reflects the current state of things as of the commit of this document. The redundancy of role and group on the permission object is something that will be teased apart.**

