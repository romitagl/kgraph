#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

function verify_hasura_env () {

  if [[ $# -ne 1 ]]; then
    printf "error - verify_hasura_env() - wrong input parameters - expected set_defaults: true/false\n"
    exit 1
  fi

  local -r set_defaults=$1

  if [[ "${set_defaults}" == "true" ]]; then
    # if console not set use false as default for the frontend check
    HASURA_GRAPHQL_ENABLE_CONSOLE=${HASURA_GRAPHQL_ENABLE_CONSOLE:-"false"}
    # frontend doesn't need the JWT secret
    HASURA_GRAPHQL_JWT_SECRET=${HASURA_GRAPHQL_JWT_SECRET:-"not-needed"}
  fi

  # developer note - add env variables to check here:
  ENV_VARIABLES=(HASURA_GRAPHQL_ADMIN_SECRET HASURA_GRAPHQL_JWT_SECRET HASURA_GRAPHQL_ENABLE_CONSOLE)

  for VARIABLE in ${ENV_VARIABLES[*]}; do
    printf "checking presence of variable %s\n" "${VARIABLE}"
    # get the value of the variable
    if [[ ! "${!VARIABLE}" ]]; then printf "missing required env variable: %s\n" "$VARIABLE" && exit 1; fi
  done

  # script depends on docker-compose - check for existence
  cmd=docker-compose
  if ! which "${cmd}" >/dev/null; then
    echo "can't find ${cmd} in PATH, please fix and retry"
    exit 1
  fi
}

function verify_hasura_running () {
  printf "checking if a graphql-engine instance is running...\n"
  # shellcheck disable=SC2046
  if [[ $( docker-compose top graphql-engine | wc -l ) -gt 0 ]]; then printf "error: found graphql-engine instance running - stop it first and re-run\n" && exit 1; fi
}