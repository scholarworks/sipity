# Sipity

[![Build Status](https://travis-ci.org/jeremyf/sipity.png?branch=master)](https://travis-ci.org/jeremyf/sipity)
[![Code Climate](https://codeclimate.com/github/jeremyf/sipity.png)](https://codeclimate.com/github/jeremyf/sipity)
[![Coverage Status](https://img.shields.io/coveralls/jeremyf/sipity.svg)](https://coveralls.io/r/jeremyf/sipity)
[![Documentation Status](http://inch-ci.org/github/jeremyf/sipity.svg?branch=master)](http://inch-ci.org/github/jeremyf/sipity)
[![APACHE 2 License](http://img.shields.io/badge/APACHE2-license-blue.svg)](./LICENSE)
[![Contributing Guidelines](http://img.shields.io/badge/CONTRIBUTING-Guidelines-blue.svg)](./CONTRIBUTING.md)

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
