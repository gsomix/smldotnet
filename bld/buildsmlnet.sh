#!/usr/bin/env bash
# Build the SML.NET command-line compiler with SML/NJ (110.99.9).
set -eu

SMLNETPATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Use SML/NJ from SMLNJ_HOME if set, otherwise from PATH
# (the build also runs ml-lex, so it has to be on the PATH)
if [ -n "${SMLNJ_HOME:-}" ]; then
  PATH="$SMLNJ_HOME/bin:$PATH"
fi

echo "Build SML.NET command-line compiler"
echo "-----------------------------------"
cd "$SMLNETPATH"

# Fills bin/tools and bin/ref (see src/clr/tools)
echo "Building SML.NET tools; log in $SMLNETPATH/bld/build.tools.log"
if ! dotnet build src/clr/tools/tools.slnx -c Release \
     > bld/build.tools.log 2>&1; then
  echo "Failed to build SML.NET tools: tail of $SMLNETPATH/bld/build.tools.log follows."
  tail -n 40 bld/build.tools.log
  exit 1
fi

echo "Building SML.NET binary; log in $SMLNETPATH/bld/build.smlnet.log"
if ! ml-build "$@" src/sources.cm TopLevel.entry bin/smlnet \
     > bld/build.smlnet.log 2>&1; then
  echo "Failed to build SML.NET compiler: tail of $SMLNETPATH/bld/build.smlnet.log follows."
  tail -n 40 bld/build.smlnet.log
  exit 1
fi
echo "Build successful"
