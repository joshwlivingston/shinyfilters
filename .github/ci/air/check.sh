#!/usr/bin/env bash
# Fails if any file isn't formatted with air.
set -euo pipefail

air format . --check
