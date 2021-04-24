#!/bin/bash

if [[ ! $HASURA_CURL_POST_COMMAND || ! "$HASURA_GRAPHQL_ENDPOINT" ]]; then printf "missing required test env variables\n" && exit 1; fi

DEFAULT_ROLE="registred_user"
ADMIN_ROLE="admin"
ROLES=("$ADMIN_ROLE" "$DEFAULT_ROLE" "anonymous")

# add all roles in configuraton
for ROLE in ${ROLES[*]}; do
  $HASURA_CURL_POST_COMMAND "{ \"query\": \"mutation { insert_kgraph_roles_one(object: {name: \\\"$ROLE\\\"}) { name } }\" }" "$HASURA_GRAPHQL_ENDPOINT"
done

# set the default role
UPDATE_RET_VAL=$( $HASURA_CURL_POST_COMMAND "{ \"query\": \"mutation { update_kgraph_roles(where: {name: {_eq: \\\"$DEFAULT_ROLE\\\"}}, _set: {default: true}) { affected_rows } }\" }" "$HASURA_GRAPHQL_ENDPOINT" )
AFFECTED_ROWS=$( echo "$UPDATE_RET_VAL" | jq .data.update_kgraph_roles.affected_rows)
if [[ $AFFECTED_ROWS != 1 ]]; then printf "failed to set default role - affected_rows: %s" "$AFFECTED_ROWS"; exit 1; else echo "default role set correctly"; fi

# set the admin role
UPDATE_RET_VAL=$( $HASURA_CURL_POST_COMMAND "{ \"query\": \"mutation { update_kgraph_roles(where: {name: {_eq: \\\"$ADMIN_ROLE\\\"}}, _set: {admin: true}) { affected_rows } }\" }" "$HASURA_GRAPHQL_ENDPOINT" )
AFFECTED_ROWS=$( echo "$UPDATE_RET_VAL" | jq .data.update_kgraph_roles.affected_rows)
if [[ $AFFECTED_ROWS != 1 ]]; then printf "failed to set admin role - affected_rows: %s" "$AFFECTED_ROWS"; exit 1; else echo "admin role set correctly"; fi