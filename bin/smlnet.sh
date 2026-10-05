#!/usr/bin/env bash
# Run the SML.NET compiler built by bld/buildsmlnet.sh.
set -eu

if [ -z "${SMLNETPATH:-}" ]; then
  SMLNETPATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi
export SMLNETPATH

# Use SML/NJ from SMLNJ_HOME if set, otherwise from PATH
if [ -n "${SMLNJ_HOME:-}" ]; then
  SML="$SMLNJ_HOME/bin/sml"
else
  SML=sml
fi

exec "$SML" @SMLload="$SMLNETPATH/bin/smlnet" "$@"
