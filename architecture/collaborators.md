# Collaborators

In Sipity's ETD module we are overloading the "collaborator" question.
A Collaborator for ETDs means two things:

* Associate metadata with the given Work
* Allow some collaborators to assist in the mediation of the Work deposit process

_See the Lexicon proposal below._

The current [Sipity::Models::Collaborator](https://github.com/ndlib/sipity/blob/f703e568fa6a258d9f89a9965cfee47014d9ce49/app/models/sipity/models/collaborator.rb) model is primarily concerned with capturing process collaborators. The model is also used to associate Metadata Collaborators at the time of ingest.

As we proceed we need to disambiguate our definition of Collaborator and acknowledge that it is an overloaded term; Some collaborators will have ongoing permission to modify and enhance a given work. Other collaborators are "for reporting purposes only".<kbd></kbd>

## Lexicon

* Process Collaborator - Someone that is assisting the in deposit process for a scholarly work.
* Metadata Collaborator - Reference to someone that assisted in the research/formation of the scholarly work being deposited.
