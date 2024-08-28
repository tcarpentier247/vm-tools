#!/bin/bash

name="$1"
test="$2"
origin="$3"
publish="$4"

printf "QA name: ${name}\n\ncode-to-test: ${test}\n\n"; printf "publish-release: $publish\n\n"; printf "$(echo "${origin}\n" | sed -e 's/%/PCT-SYMBOL/g')"
