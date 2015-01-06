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
