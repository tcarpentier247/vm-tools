#!/bin/bash

# /data/vdc/build/common/show-job-origin-v3.sh --qa "${option.qa-name}" --code "${option.code-to-test}" --origin "${option.job-origin}" --gitcommitid "${option.commit-id}"

CODE="${CODE}"
COMMIT="${COMMIT}"
NAME="${NAME}"
ORIGIN="${ORIGIN}"

printf "QA name: ${NAME}\n\ncode-to-test: ${CODE}\n\n"

printf "commit-id: ${COMMIT}\n\n"

printf "$(echo "${ORIGIN}\n" | sed -e 's/%/PCT-SYMBOL/g')"
