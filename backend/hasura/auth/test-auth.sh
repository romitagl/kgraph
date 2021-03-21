#!/bin/bash

declare -a users_array

create_users(){
  # echo "execution n. $1"
  INSERT_RET_VAL=$( $HASURA_CURL_POST_COMMAND "{ \"query\": \"mutation { Signup(signupParams: {username: \\\"test${i}\\\", password: \\\"test${i}\\\"}) { username } }\" }" "$HASURA_GRAPHQL_ENDPOINT" )
  USERNAME=$( echo "$INSERT_RET_VAL" | jq .data.Signup.username )
  printf "Created User: %s\n" "$USERNAME"
  users_array+=("$USERNAME")
  # echo "users_array: " ${users_array[@]}
}

login_users(){
  echo "Authenticating User " "$USER"
  LOGIN_RET_VAL=$( $HASURA_CURL_POST_COMMAND "{ \"query\": \"mutation { Login(loginParams: {username: \\\"${USER}\\\", password: \\\"${USER}\\\"}) { token } }\" }" "$HASURA_GRAPHQL_ENDPOINT" )
  RETURNED_TOKEN=$( echo "$LOGIN_RET_VAL" | jq .data.Login.token )
  if [[ ! $RETURNED_TOKEN ]]; then
    exit 1;
  fi
}

for i in {1..10}
do
	create_users "$i"
done

printf "\n"

for USER in "${users_array[@]}"; do
  time login_users "$USER" & # Put the working function in the background
done

wait
echo "All done"
