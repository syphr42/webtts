#!/usr/bin/env sh

TEST_HOST="${TEST_HOST:?The environment variable 'TEST_HOST' must be set and non-empty}"

curl -v -s -I -w "%{http_code}" -X GET "http://$TEST_HOST/tts.php?lng=en-US&msg=Hello+World" | grep -q 200
