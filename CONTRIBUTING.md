# Getting Started

* Clone the repository
* Run `$ bundle`
* Run `$ rake bootstrap`

# Starting an Issue

```console
$ ./scripts/start-issue <the-issue-number>
```

See [./scripts/start-issue](https://github.com/ndlib/sipity/blob/master/scripts/start-issue) for further details.

# I Don't Know What To Do

If you are just joining the project, or are unclear what to do, how about helping with documentation?

We are leveraging [inch-ci.org](http://inch-ci.org) to show us where we might be able to improve [our documentation](http://inch-ci.org/github/ndlib/sipity).

* Find a line from [Sipity's Inch-CI build](http://inch-ci.org/github/ndlib/sipity)
* Make a new branch
* Follow the suggestions as you write the inline documentation
* Run `$ yard` and open the `./doc/index.html` to review your changes
* Submit a pull request; Don't forget to add a `[skip ci]` line to the git commit message

# Run Guard During Development

Guard will watch for changes in your code, run your tests in the background, and notify you of their success or failure.
Run it with:
```console
bundle exec guard
```

This project relies on [terminal-notifier-guard](https://rubygems.org/gems/terminal-notifier-guard) which in, turn relies on the `terminal-notifer` command line tool.
Install it with:

```console
brew install terminal-notifier
```
For more information see the [terminal-notifier project page](https://github.com/alloy/terminal-notifier).

# Verifying the Build

Travis builds enforce code style guide compliance in addition to running the test suite.
If any test or lint check fails the build will fail.

Adding a `pre-push` hook to git will help catch issues _before_ sending the build to CI.
Install a `pre-push` hook by copying and pasting the following into your terminal:

```console
echo '#!/bin/sh
SPEC_OPTS="--format progress" bin/rake spec:travis' > .git/hooks/pre-push ; chmod +x .git/hooks/pre-push
```

If you need to skip the `pre-push` hook, use the `--no-verify` option when you push to a branch.

## Build Goals

* Our test suite must complete in 30 seconds or less
* Our code coverage must be 100%
* Our code must have 100% style guide compliance
  - Or a clear reason for exclusion
* Our code will have a 3.75 or higher grade on [Code Climate](https://codeclimate.com/github/ndlib/sipity)

A slow test suite is an indicator of an unhealthy test suite;
Therefore lets keep it under 30 seconds.

Code that is not covered in test means code that we are not "owning" and documenting.
Let's keep the test coverage at 100%.

### What Happens We Pass the 30 Second Threshold?

Our application is going to continue to grow; And so will the completion time of our tests.
If we hit the 30 second mark, we'll review what is happening and adjust the goal.

### The linters are complaining too much...

Programatic style guide enforcement keeps the codebase consistent and gives contributors immediate feedback on whether their code meeds the expectations of this project.
By pre-screening for formatting and whitespace concerns pull request conversations can focus on _intent_ and _clarity_.

We recognize that there are times when exceptions to the style guides are justified.
Submit a pull request modifying the pertinent configuration file and we can discuss it.
* [RuboCop](https://github.com/bbatsov/rubocop) configuration is in `.hound.yml`
* [SCSS-Lint](https://github.com/causes/scss-lint) configuration is in `.scss-lint.yml`
* [JSHint](https://github.com/jshint/jshint/) configuration is in `.jshintrc`. Files can be excluded from JSHint checks by adding them to `.jshintignore`

# Submitting a Pull Request

When submitting a pull request, make sure to submit a useful description of what you are doing.
If your pull request contains multiple commits, consider using `./script/build-multi-commit-message`.
It will generate rudimentary markdown from all of the commit messages.

# The Layers

There are lots of layers in Sipity.
They are there for a reason.
One reason, is to **reduce the need to persist data** as part of tests.

If you find yourself persisting an object as part of your test, ask is there another way?

Consider the `Sipity::QueryRepositoryInterface` and `Sipity::CommandRepositoryInterface` and using those for mocks.
They are designed to implement each of the methods and have the correct method signature.

**Why the fuss about hitting the database?**

> There are a number of advantages to writing unit tests that never touch the database.
> The biggest is probably speed of execution - unit tests must be fast for test-driven development to be practical.
> Another is separation of concerns: unit tests should be exercising only the business logic contained in your models, not ActiveRecord.
>
> From [nulldb gem](https://github.com/nulldb/nulldb)

So before you persist an object as part of setting up your fixtures, consider if there is a different way.