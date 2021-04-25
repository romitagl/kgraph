#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

declare -a users_array

create_users() {
  if [[ ! $1  ]]; then printf "missing required input user variable\n" && exit 1; fi
  local -r USER="$1"
  # echo "execution n. $1"
  INSERT_RET_VAL=$( $HASURA_CURL_POST_COMMAND "{ \"query\": \"mutation { Signup(signupParams: {username: \\\"test${USER}\\\", password: \\\"test${USER}\\\"}) { username } }\" }" "$HASURA_GRAPHQL_ENDPOINT" )
  USERNAME=$( echo "$INSERT_RET_VAL" | jq .data.Signup.username )
  if [[ ! $USERNAME || $USERNAME == 'null' ]]; then
    printf "create_users - error creating: %s\n" "$USER"
    exit 1;
  fi
  printf "Created User: %s\n" "$USERNAME"
  users_array+=("$USERNAME")
  # echo "users_array: " ${users_array[@]}
}

login_users() {
  if [[ ! $1  ]]; then printf "missing required input user variable\n" && exit 1; fi
  local -r USER=$1
  echo "Authenticating User " "$USER"
  # curl -H "X-Hasura-Admin-Secret:hasura-admin-secret" --data '{ "query" : "mutation Login($username: String!) { Login(loginParams: {password: $username, username: $username}) { token } }", "variables": { "username" : "test1" }}' http://127.0.0.1:8080/v1/graphql
  LOGIN_RET_VAL=$( $HASURA_CURL_POST_COMMAND "{ \"query\": \"mutation Login(\$username: String!) { Login(loginParams: {password: \$username, username: \$username}) { token } }\" , \"variables\": { \"username\" : ${USER} } }" "$HASURA_GRAPHQL_ENDPOINT" )
  printf "login_users - login return value: %s\n" "$LOGIN_RET_VAL"
  TOKEN=$( echo "$LOGIN_RET_VAL" | jq .data.Login.token )
  printf "login_users - token: %s\n" "$TOKEN"
  if [[ ! $TOKEN || $TOKEN == 'null' ]]; then
    exit 1;
  fi
}

for i in {1..10}
do
	create_users "$i"
done

printf "\n"

for USER in "${users_array[@]}"; do
  time login_users "$USER" # Put the working function in the background
done

echo "All done"
