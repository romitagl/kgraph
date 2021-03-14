#!/bin/bash

if [[ ! $HASURA_CURL_POST_COMMAND || ! "$HASURA_GRAPHQL_ENDPOINT" ]]; then printf "missing required test env variables\n" && exit 1; fi

kg_test_username=${KG_TEST_USERNAME:-"ci_test"}
kg_test_topicname=${TOPICNAME:-"test topic"}

function test_add_topic () {
  # 0. cleanup the users table
  $HASURA_CURL_POST_COMMAND "{ \"query\": \"mutation { delete_kgraph_users(where: {username: {_eq: \\\"$kg_test_username\\\"}}) { affected_rows }}\" }" "$HASURA_GRAPHQL_ENDPOINT"

  # 1. create an entry in the users table
  # INSERT_RET_VAL=$( $HASURA_CURL_POST_COMMAND "{ \"query\": \"mutation { insert_kgraph_users(objects: {username: \\\"$kg_test_username\\\", display_name: \\\"$kg_test_username\\\"}) { returning { created_at } } }\" }" "$HASURA_GRAPHQL_ENDPOINT" )
  # printf "created user: %s at: %s\n" "$kg_test_username" "$INSERT_RET_VAL"
  INSERT_RET_VAL=$( $HASURA_CURL_POST_COMMAND "{ \"query\": \"mutation { Signup(signupParams: {username: \\\"$kg_test_username\\\", password: \\\"$kg_test_username\\\"}) { username } }\" }" "$HASURA_GRAPHQL_ENDPOINT" )
  printf "User signup: %s\n" "$INSERT_RET_VAL"
  # User signup: {"data":{"Signup":{"username":"ci_test"}}}
  USERNAME=$( echo "$INSERT_RET_VAL" | jq .data.Signup.username | tr -d '"' )

  if [[ "$USERNAME" != "$kg_test_username" ]]; then
    printf "error: username [%s] not matching expected value [%s]!" "$USERNAME" "$kg_test_username"
    exit 1;
  fi

  # 2. add a topic
  TOPIC_ID_RESULT=$( $HASURA_CURL_POST_COMMAND "{ \"query\": \"mutation { insert_kgraph_topics(objects: {users_username: \\\"$kg_test_username\\\", name: \\\"$kg_test_topicname\\\"}) { returning { id } } }\" }" "$HASURA_GRAPHQL_ENDPOINT" )
  printf "added topic: %s with id: %s\n" "$kg_test_topicname" "$TOPIC_ID_RESULT"

  # 3. get the topic by ID
  TOPIC_ID=$( echo "$TOPIC_ID_RESULT" | jq .data.insert_kgraph_topics.returning[0].id | tr -d '"' )
  TOPICNAME_RESULT=$( $HASURA_CURL_POST_COMMAND "{\"query\": \"query { kgraph_topics(where: {id: {_eq: \\\"$TOPIC_ID\\\" }}) { name }}\" }" "$HASURA_GRAPHQL_ENDPOINT" )
  printf "get topic: %s with id: %s\n" "$TOPICNAME_RESULT" "$TOPIC_ID"

  TOPICNAME_NAME=$( echo "$TOPICNAME_RESULT" | jq .data.kgraph_topics[0].name | tr -d '"' )
  # 4. verify that TOPICNAME matches TOPICNAME_NAME
  if [[ "$kg_test_topicname" != "$TOPICNAME_NAME" ]]; then
    exit 1;
  fi
}

function test_drop_all_data () {
  # 0. cleanup the users table => cascade on topics
  $HASURA_CURL_POST_COMMAND "{ \"query\": \"mutation { delete_kgraph_users(where: {}) { affected_rows }}\" }" "$HASURA_GRAPHQL_ENDPOINT"
}

function test_check_ci_topic () {

  TOPICID_RESULT=$( $HASURA_CURL_POST_COMMAND "{\"query\": \"query { kgraph_topics(where: {users_username: {_eq: \\\"$kg_test_username\\\" }, name: {_eq: \\\"$kg_test_topicname\\\"}}) { id }}\" }" "$HASURA_GRAPHQL_ENDPOINT" )
  printf "get topic: %s with name: %s\n" "$TOPICID_RESULT" "$kg_test_topicname"
  TOPICID=$( echo "$TOPICID_RESULT" | jq .data.kgraph_topics[0].id | tr -d '"' )

  if [[ ! "$TOPICID" ]]; then
    printf "error: topic id not found!!"
    exit 1;
  fi
}