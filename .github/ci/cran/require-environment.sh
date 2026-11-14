#!/usr/bin/env bash
# Fails unless CRAN_ENVIRONMENT is 'true'. GitHub creates a missing
# environment with no protection, so only a `cran` environment set up with a
# required reviewer and this variable may submit. Set the variable on the
# environment only, never on the repository: `vars` merges both.
set -euo pipefail

if [ "${CRAN_ENVIRONMENT:-}" != "true" ]; then
  echo "::error::The cran environment isn't configured: it needs a required reviewer and the variable CRAN_ENVIRONMENT=true."
  exit 1
fi
