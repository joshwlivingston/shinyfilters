#!/usr/bin/env bash
# TinyTeX doesn't include makeindex, which R-devel needs to build the PDF
# manual's index.
set -euo pipefail

tlmgr install makeindex
