# Sipity

[![Build Status](https://travis-ci.org/ndlib/sipity.png?branch=master)](https://travis-ci.org/ndlib/sipity)
[![Code Climate](https://codeclimate.com/github/ndlib/sipity.png)](https://codeclimate.com/github/ndlib/sipity)
[![Coverage Status](https://img.shields.io/coveralls/ndlib/sipity.svg)](https://coveralls.io/r/ndlib/sipity)
[![Documentation Status](http://inch-ci.org/github/ndlib/sipity.svg?branch=master)](http://inch-ci.org/github/ndlib/sipity)
[![APACHE 2 License](http://img.shields.io/badge/APACHE2-license-blue.svg)](./LICENSE)
[![Contributing Guidelines](http://img.shields.io/badge/CONTRIBUTING-Guidelines-blue.svg)](./CONTRIBUTING.md)

Sipity is a patron-oriented deposit interface into CurateND.
Its goal is to provide clarity on why a patron would want to fill out metadata information.

* Does the patron want a DOI? Ask them to provide a publisher and publication date.
* Does the patron want to include the works citation? Encourage them to fill out the component fields for building a citation, or have them provide the citation.
* Does the patron want their deposit to be listed in Google Scholar? Fill out this information.
* Does the patron want other people to assist them on editing this information? Fill out this particular information.

## Getting Your Bearings

Sipity is a Rails application but is built with a few more concepts in mind.

The Sip::Repository object exposes the methods for interacting with the persistence layer.
You can circumvent this, but I prefer the expressiveness of the methods.

The Runners expose how the application interacts with the persistence layer.
Conceptually a Runner is either a Query or a Command.
In either case, the Runner's #run method is called and it issues one of several arbitrary callbacks.

## Anatomy of Sipity

```
app
|-- assets
|-- controllers
|-- forms
|-- helpers
|-- mailers
|-- models
|-- presenters
|-- runners
|-- services
|-- views
```

### Assets, Controllers, Helpers, Mailers, Models, Views

The usual Rails suspects.

### Forms

Forms are a class of objects that are different from models. They may represent
a subset of a single model's attributes, or be a composition of multiple
objects.

Regardless their purpose is to:

* Expose attributes
* Validate attributes

They are things that could be rendered via the `simple_form_for` view template
method.

As of the writing of this, I'm not making use of Nick Sutterer's fantastic
Reform gem. Though it could make its way into this application.

### Presenters

Take a look at the [Draper gem](https://github.com/drapergem/draper). It does a
great job of explaining their importance.

### Runners

This is a step towards crafting a single class per Controller action.
They are an implementation idea of the late Jim Weirich and provide a fantastic
means of pulling even more logic out of the overworked Rails controller.

### Services

Of particular note is the Sip::Repository class. Here are methods for
interacting with the persistence layer; either by way of commands or queries.

It can also represent the grand dumping bucket of objects that do things.
