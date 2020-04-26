#!/bin/bash

. ../env.sh

$KG_DGRAPH_CURL_POST_COMMAND "{ \"query\": \"query {__schema { types { name } }}\" }" $KG_DGRAPH_GRAPHQL_ENDPOINT
