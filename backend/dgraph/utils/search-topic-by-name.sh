#!/bin/bash

. ../env.sh

if [ $# -ne 1 ]
  then
    echo Missing input parameter: "name"
    exit 1
fi

NAME=$1

$KG_DGRAPH_CURL_POST_COMMAND "{ \"query\": \"query { queryTopic (filter:{name:{alloftext:\\\"$NAME\\\"}}) { name id user { name } } }\" }" $KG_DGRAPH_GRAPHQL_ENDPOINT
