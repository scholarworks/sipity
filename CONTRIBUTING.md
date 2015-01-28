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

Travis is set to run both Rubocop and the test suite.
If either task fails, the build will fail.

I have configured my git `pre-push` hook to run those tests.
You can do the same by copying and pasting the text below into your terminal.

```console
echo '#!/bin/sh
SPEC_OPTS="--format progress" bin/rake spec:travis' > .git/hooks/pre-push ; chmod +x .git/hooks/pre-push
```

If you need to skip the `pre-push` hook, use the `--no-verify` option when you push to a branch.

## But Rubocop is complaining too much...

Either submit a pull request modifying the `.hound.yml` file or submit an issue
and I can take a look at it.

# Submitting a Pull Request

When submitting a pull request, make sure to submit a useful description of what you are doing.
If your pull request contains multiple commits, consider using `./script/build-multi-commit-message`.
It will generate rudimentary markdown from all of the commit messages.