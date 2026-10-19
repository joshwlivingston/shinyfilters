#!/usr/bin/env bash
# TinyTeX doesn't include makeindex, which R-devel needs to build the PDF
# manual's index.
set -euo pipefail

# On Windows, TinyTeX ships tlmgr only as tlmgr.bat, which bash doesn't find
# by its bare name.
if command -v tlmgr > /dev/null 2>&1; then
  tlmgr install makeindex
else
  tlmgr.bat install makeindex
fi
