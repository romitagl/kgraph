#!/bin/bash

. ../env.sh

if [ $# -ne 1 ]
  then
    echo "usage: bash create-user.sh name"
    exit 1
fi

USER_NAME=$1

$KG_DGRAPH_CURL_POST_COMMAND "{ \"query\": \"mutation { addUser(input: [{name: \\\"$USER_NAME\\\"}]) { user { name } } }\" }" $KG_DGRAPH_GRAPHQL_ENDPOINT
