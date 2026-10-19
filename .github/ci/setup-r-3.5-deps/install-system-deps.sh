#!/usr/bin/env bash
# System libraries for building R 3.5's dependencies from source on Ubuntu.
set -euo pipefail

sudo apt-get update
sudo apt-get install -y make zlib1g-dev libicu-dev libxml2-dev libcurl4-openssl-dev libssl-dev
