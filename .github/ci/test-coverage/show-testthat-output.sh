#!/usr/bin/env bash
# Prints the testthat output from the coverage run, if there is any.
set -uo pipefail

find "$RUNNER_TEMP/package" -name 'testthat.Rout*' -exec cat '{}' \; || true
