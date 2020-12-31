#!/bin/bash

# developer note - add env variables to check here:
ENV_VARIABLES=(HASURA_GRAPHQL_ADMIN_SECRET HASURA_GRAPHQL_ENABLE_CONSOLE)

for VARIABLE in ${ENV_VARIABLES[*]}; do
  printf "checking presence of variable %s\n" "${VARIABLE}"
  # get the value of the variable
  if [[ ! "${!VARIABLE}" ]]; then printf "missing required env variable: %s\n" "$VARIABLE" && exit 1; fi
done