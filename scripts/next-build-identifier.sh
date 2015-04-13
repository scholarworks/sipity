#!/usr/bin/env bash

# Determine the next build number with the format: "v2013.12"

current_year=$(date "+%Y")

# Oye! Find a build in the current year. Munge it so we can sort things. Grab the latest build. Then reconstitute to build format.
current_build=$(git tag | grep ^v$current_year\.[0-9]*$ | sed -e 's/^v\([0-9]*\)\.\([0-9]*\)$/\2\1/' | sort -nr | head -1 | sed -e 's/^\([0-9]*\)\([0-9][0-9][0-9][0-9]\)$/v\2.\1/')
if [ -z $current_build ]
then
  current_build="v$current_year.0"
else
  build_year=$(echo $current_build | sed -e 's/^v\([0-9]*\)\.\([0-9]*\)$/\1/')
  if [ "$current_year" != "$build_year" ]
  then
    current_build="v$current_year.0"
  fi
fi
current_minor_build=$(echo $current_build | sed -e 's/^[^\.]*\.//')
next_minor_build=$(expr $current_minor_build + 1)
next_major_build=$(echo $current_build | sed -e 's/^v\([0-9]*\)\.\([0-9]*\)$/v\1./')
next_build="$next_major_build$next_minor_build"
echo "$next_build"
exit 0
