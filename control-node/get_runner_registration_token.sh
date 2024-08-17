#!/bin/bash -e

# Copyright © 2024 Bitcrush Testing

ORGANISATION="bitcrushtesting"

echoerr() { echo "$@" 1>&2; }

if ! command -v gh &> /dev/null; then
    echoerr "Github CLI could not be found"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echoerr "jq command could not be found"
    exit 1
fi

gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /orgs/${ORGANISATION}/actions/runners/registration-token | jq -r '.token'
