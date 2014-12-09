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

The Sipity::Repository object exposes the methods for interacting with the persistence layer.
You can circumvent this interaction, but I am looking to convey the concepts in an expressive manner.

The Runners, found in `./app/runners`, define how the application interacts with the repository layer.
The primary purpose of the Runner is to offload much of the processing decisions from the controller.
And instead let the controller worry about generating the correct response (e.g. render a template or redirect to another URI) based on the results of the Runner.

In offloading the processing from the controller, the runner can, with minimal adjustments, operate in a different context.
In other words, a Runner could be used to build a suite of command-line commands.

### RSpec output

Don't forget, you can run `rspec --format documentation` (or its equivalent `rspec -f d`) to run the tests and output a "self-documentation" format.
I am doing my best to re-read the output tests to make sure they are adequate/accurate low-level documentation.

## Anatomy of Sipity

```
app
|-- assets
|-- controllers
|-- forms
|-- helpers
|-- mailers
|-- models
|-- policies
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

### Policies

Take a look at the [Pundit gem](https://github.com/elabs/pundit). Sipity is
implementing policies that adhere to the interface of Pundit Policy and Scope
objects.

### Runners

This is a step towards crafting a single class per Controller action.
They are an implementation idea of the late Jim Weirich and provide a fantastic
means of pulling even more logic out of the overworked Rails controller.

### Services

Of particular note is the Sipity::Repository class. Here are methods for
interacting with the persistence layer; either by way of commands or queries.

It can also represent the grand dumping bucket of objects that do things.
