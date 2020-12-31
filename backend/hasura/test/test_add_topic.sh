#!/bin/bash

if [[ ! "$HASURA_CURL_POST_COMMAND" || ! "$HASURA_GRAPHQL_ENDPOINT" ]]; then printf "missing required test env variables\n" && exit 1; fi

USERNAME='ci_test'
# 0. cleanup the users table
$HASURA_CURL_POST_COMMAND "{ \"query\": \"mutation { delete_kgraph_users(where: {username: {_eq: \\\"$USERNAME\\\"}}) { affected_rows }}\" }" $HASURA_GRAPHQL_ENDPOINT

# 1. create an entry in the users table
INSERT_RET_VAL=$( $HASURA_CURL_POST_COMMAND "{ \"query\": \"mutation { insert_kgraph_users(objects: {username: \\\"$USERNAME\\\", display_name: \\\"$USERNAME\\\"}) { returning { created_at } } }\" }" $HASURA_GRAPHQL_ENDPOINT )
printf "created user: %s at: %s\n" "$USERNAME" "$INSERT_RET_VAL"

# 2. add a topic
TOPICNAME='test topic'
TOPIC_ID_RESULT=$( $HASURA_CURL_POST_COMMAND "{ \"query\": \"mutation { insert_kgraph_topics(objects: {users_username: \\\"$USERNAME\\\", name: \\\"$TOPICNAME\\\"}) { returning { id } } }\" }" $HASURA_GRAPHQL_ENDPOINT )
printf "added topic: %s with id: %s\n" "$TOPICNAME" "$TOPIC_ID_RESULT"

# 3. get the topic by ID
TOPIC_ID=$( echo "$TOPIC_ID_RESULT" | jq .data.insert_kgraph_topics.returning[0].id | tr -d '"' )
TOPICNAME_RESULT=$( $HASURA_CURL_POST_COMMAND "{\"query\": \"query { kgraph_topics(where: {id: {_eq: \\\"$TOPIC_ID\\\" }}) { name }}\" }" $HASURA_GRAPHQL_ENDPOINT )
printf "get topic: %s with id: %s\n" "$TOPICNAME_RESULT" "$TOPIC_ID"

TOPICNAME_NAME=$( echo "$TOPICNAME_RESULT" | jq .data.kgraph_topics[0].name | tr -d '"' )
# 4. verify that TOPICNAME matches TOPICNAME_NAME
if [ "$TOPICNAME" != "$TOPICNAME_NAME" ]; then
  exit 1;
fi
