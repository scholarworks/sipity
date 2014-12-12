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

![Sipity Request Cycle](artifacts/sipity-request-cycle.png)


1. A request comes into the Router.
2. Router maps request to a Controller.
3. Controller maps request to a Runner.
4. Runner enforces Authentication layer
5. Runner enforces Authorization layer
6. Runner processes request by collaborating with the Repository and Job.
7. Runner generates response for the Controller.
8. Controller passes response through Decoration layer.
9. Controller generates response for Responder.
10. Responder sends response to the request.

### RSpec output

Don't forget, you can run `rspec --format documentation` (or its equivalent `rspec -f d`) to run the tests and output a "self-documentation" format.
I am doing my best to re-read the output tests to make sure they are adequate/accurate low-level documentation.

## Anatomy of Sipity

Below is a list of the various concepts of Sipity.

```
app
|-- assets
|-- controllers
|-- conversions
|-- decorators
|-- forms
|-- jobs
|-- helpers
|-- mailers
|-- models
|-- policies
|-- runners
|-- services
|-- views
```

### Cohesion, Orthogonality, and Decoupling

I am working to keep the various concepts of Sipity loosely coupled.
I use the various `rake spec:<layer>:coverage` tasks to help me understand how each layer's specs cover that layer's code.

My conjecture is that if each layer's specs cover the entire layer:

* I have a well documented internal API.
* My feature tests can focus on integration of the various layers.

### Assets, Controllers, Helpers, Mailers, Models, Views

The usual Rails suspects.

Jeremy's Admonition:

* **Though shalt not put behavior in ActiveRecord objects**
  - This means:
    * No callbacks - prefer repository service/command objects/methods
    * No query scopes - prefer repository query objects/methods
    * No conditional validations - prefer form objects
* **Though shalt not use ActionController filters**
  - This means:
    * Pushing authentication to another layer
    * Pushing authorization to another layer
    * Pushing cache management to another layer
* **Though shalt think about command line interaction**
  - This means:
    * The controllers are one of many possible clients for the underlying application

### Conversions

Taking a que from Avdi Grimm's "Confident Ruby", Conversions are responsible for coercing the input to another format.
The Conversions modules are designed to be either:

* callable via module functions
* includable and thus exposing the underlying conversion

Find out more about [Sipity's Conversions](https://github.com/ndlib/sipity/blob/master/app/conversions/sipity/conversions.rb)

### Decorators

Take a look at the [Draper gem](https://github.com/drapergem/draper). It does a
great job of explaining their importance.

Find out more about [Sipity's Decorators](https://github.com/ndlib/sipity/blob/master/app/decorators/sipity/decorators.rb)

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

Find out more about [Sipity's Forms](https://github.com/ndlib/sipity/blob/master/app/forms/sipity/forms.rb)

### Jobs

Find out more about [Sipity's Jobs](https://github.com/ndlib/sipity/blob/master/app/jobs/sipity/jobs.rb)

### Policies

Take a look at the [Pundit gem](https://github.com/elabs/pundit). Sipity is
implementing policies that adhere to the interface of Pundit Policy and Scope
objects.

Find out more about [Sipity's Policies](https://github.com/ndlib/sipity/blob/master/app/policies/sipity/policies.rb)

### Runners

This is a step towards crafting a single class per Controller action.
They are an implementation idea of the late Jim Weirich and provide a fantastic
means of pulling even more logic out of the overworked Rails controller.

Find out more about [Sipity's Runners](https://github.com/ndlib/sipity/blob/master/app/runners/sipity/runners.rb)

### Services

Of particular note is the Sipity::Repository class. Here are methods for
interacting with the persistence layer; either by way of commands or queries.

It can also represent the grand dumping bucket of objects that do things.
