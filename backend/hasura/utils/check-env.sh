#!/bin/bash

function verify_hasura_env () {
  # developer note - add env variables to check here:
  ENV_VARIABLES=(HASURA_GRAPHQL_ADMIN_SECRET HASURA_GRAPHQL_ENABLE_CONSOLE)

  for VARIABLE in ${ENV_VARIABLES[*]}; do
    printf "checking presence of variable %s\n" "${VARIABLE}"
    # get the value of the variable
    if [[ ! "${!VARIABLE}" ]]; then printf "missing required env variable: %s\n" "$VARIABLE" && exit 1; fi
  done

  # script depends on docker-compose - check for existence
  cmd=docker-compose
  if ! which "${cmd}" >/dev/null; then
    echo "Can't find ${cmd} in PATH, please fix and retry"
    exit 1
  fi
}

function verify_hasura_running () {
  printf "checking if a graphql-engine instance is running...\n"
  # shellcheck disable=SC2046
  if [[ $( docker-compose top graphql-engine | wc -l ) -gt 0 ]]; then printf "error: found graphql-engine instance running - stop it first and re-run\n" && exit 1; fi
}