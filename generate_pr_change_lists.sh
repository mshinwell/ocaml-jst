#!/bin/bash

set -eu -o pipefail

from_rev=5.1.1
to_rev=5.2.0
github_url=https://github.com/ocaml/ocaml/

root_files="\
  Makefile \
  Makefile.best_binaries \
  Makefile.build_config.in \
  Makefile.common \
  Makefile.config.in \
  Makefile.config_if_required \
  Makefile.dev \
  Makefile.menhir \
  aclocal.m4 \
  build-aux \
  configure.ac \
  dune \
  dune-project \
  ocaml-variants.opam"

dirs="\
  asmcomp \
  bytecomp \
  compilerlibs \
  debugger \
  driver \
  file_formats \
  lambda \
  middle_end \
  ocamltest \
  otherlibs \
  parsing \
  runtime \
  stdlib \
  testsuite \
  tools \
  toplevel \
  typing \
  utils \
  yacc"

echo "# Changes from $from_rev to $to_rev"
echo

extract_changesets() {
  title="$1"
  targets="$2"
  log=$(mktemp)

  git log --first-parent --format=oneline ${from_rev}..${to_rev} $targets > $log

  echo "## $targets"
  echo

  while read line; do
    rev=$(echo $line | sed 's/ .*//')
    desc=$(echo $line | sed 's/^[^ ]* //')
    if grep "^Merge pull request #" <(echo $desc) 2>&1 > /dev/null; then
      pr=$(echo $line | sed 's/.*Merge pull request #\([0-9][0-9]*\) .*/\1/')
      title=$(gh pr view --repo ocaml/ocaml $pr | head -1 | sed 's/^title:\t*//')
      echo "\`$rev | merge PR$pr |\` [$title](${github_url}/pull/$pr)  "
    else
      echo "\`$rev | non-merge     |\` [$desc](${github_url}/commit/$rev)  "
    fi
#    echo
  done < $log

  echo

  rm -f $log
}

for dir in $dirs; do
  extract_changesets "$dir" "$dir"
done

extract_changesets "Files at the root" "$root_files"

