#!/bin/bash

. ../env.sh

if [ $# -ne 2 ]
  then
    echo "usage: bash create-user.sh topic user"
    exit 1
fi

TOPIC=$1
USER=$2

$KG_DGRAPH_CURL_POST_COMMAND "{ \"query\": \"mutation { addTopic(input:[{name:\\\"$TOPIC\\\", permission:Private, user:{name:\\\"$USER\\\"}}]) { topic { name id } } }\" }" $KG_DGRAPH_GRAPHQL_ENDPOINT
