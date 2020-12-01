#!/bin/bash

#  -- DGRAPH ENV VARIABLES -- 

export KG_DOCKER_IMAGE=dgraph/dgraph
export KG_DOCKER_IMAGE_VERSION=v20.07.2

export KG_DGRAPH_BASE_URL="http://localhost:8080"
export KG_DGRAPH_GRAPHQL_ENDPOINT="$KG_DGRAPH_BASE_URL/graphql"
export KG_DGRAPH_CURL_POST_COMMAND="curl --request POST -H Content-Type:application/json -d"
