#!/bin/bash

set -xeuo pipefail

TEST_HOST="${TEST_HOST:?The environment variable 'TEST_HOST' must be set and non-empty}"

curl \
  --verbose \
  --silent \
  --show-error \
  --head \
  --write-out "%{http_code}" \
  "http://${TEST_HOST}/tts.php?lng=en-US&msg=Hello+World" | grep -q 200
