# Localization and Translation

The processing actions are represented through a Form object.
Each form object is associated with a processing entity.
At present processing entities represent one of three things:

* Sipity::Models::Work
* Sipity::Models::WorkArea
* Sipity::Models::SubmissionWindow

Instead of managing all of localizations of the different form objects through separate translation keys,
I want to see these unified and predictable.

I am assessing the gnarly localization/translation needs:

* **Form Labels** for input fields on "command pages"
* **Form Hints** input fields on "command pages"
* **Show Labels** for predicates on "query pages"
* **Form Error Messages** on "command pages"

As I've looked through the implementation of ActiveModel::Name and SimpleForm
there are a few things:

## Form Labels

SimpleForm uses the :object_name derived from the `:as` option or `#param_key`.
This is known as the form's `object_name`.
When posting a form, the object_name is the hash key for the posted attributes.

- `simple_form_for :user` would be 'user'
- `simple_form_for @user` would be 'user' (assuming User.model_name.param_key == 'user')
- `simple_form_for @user, as: :ketchup` would be 'ketchup'

If there is no hit on the `object_name` and attribute name SimpleForm will try
the `defaults` and attribute name.
If that fails, SimpleForm will pass the responsibility up to the object class's `human_attibute_name` method.
(Yes, the Law of Dememeter is being violated with that concession).

## For Hints

As the Labels, but there is no fallback on `human_attribte_name` of the object's class.

## Show Labels

The logical method is to fallback on the `human_attribute_name` of the object's class.

## Form Error Messages

Leverages `errors` from the underlying model, which in turn goes through the `.lookup_ancestors` of the object's class.

# Plan

For each Form object, expose a `#model_name` object.
That `#model_name` object would return an `ActiveModel::Naming` instance that was built with an object that responds to:

* `#name` (and returns the concept it was using: Work, SubmissionWindow, WorkArea)
* `#lookup_ancestors` (and returns `[]`, is that correct?)
* `#i18n_scope` (and returns the correct scope)

This leverages the implementation details of `ActiveModel::Name`.
I am hesitant to choose this implementation, but I'd prefer this over implementing the ActiveModel::Name interface.
If I implemented the ActiveModel::Name interface I would miss out on the fallback of `human_attribute_name`; Which will
rescue me from insanity.

Going forward, I would want to push the :hint behavior to the form object:

```ruby
<%= f.input :title, hint: f.object.hint(:title) %>
```