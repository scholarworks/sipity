# Verifying the Build

Travis is set to run both Rubocop and the test suite.
If either task fails, the build will fail.

I have configured my git `pre-push` hook to run those tests.
You can do the same by copying and pasting the text below into your terminal.

```console
echo '#!/bin/sh
rake spec:travis' > .git/hooks/pre-push ; chmod +x .git/hooks/pre-push
```

## But Rubocop is complaining too much...

Either submit a pull request modifying the `.hound.yml` file or submit an issue
and I can take a look at it.
