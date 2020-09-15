#!/bin/bash

. ../env.sh

if [ $# -ne 3 ]
  then
    echo "usage: bash create-user.sh topic user child"
    exit 1
fi

TOPIC=$1
USER=$2
CHILD=$3

$KG_DGRAPH_CURL_POST_COMMAND "{ \"query\": \"mutation { addTopic(input:[{name:\\\"$TOPIC\\\", permission:Private, user:{name:\\\"$TOPIC\\\"}, childTopics:[{name:\\\"$CHILD\\\", permission:Private, user:{name:\\\"$USER\\\"}}]}]) { topic { name id childTopics { name } } } }\" }" $KG_DGRAPH_GRAPHQL_ENDPOINT
