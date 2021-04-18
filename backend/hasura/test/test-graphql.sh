#!/bin/bash

if [[ ! $HASURA_CURL_POST_COMMAND || ! "$HASURA_GRAPHQL_ENDPOINT" ]]; then printf "missing required test env variables\n" && exit 1; fi

while [[ $( curl -o /dev/null -L -I -w "%{http_code}" "$HASURA_GRAPHQL_ENDPOINT" ) != 404 ]] ; do echo "waiting for Hasura GraphQL endpoint to be ready - retrying in 10 seconds..."; sleep 10; done

kg_test_topicname=${TOPICNAME:-"test topic"}
kg_test_labelname=${LABELNAME:-"label1"}

function test_add_topic () {

  if [[ $# -ne 1 ]]; then
    printf "error - test_add_topic() - wrong input parameters - expected username\n"
    exit 1
  fi

  local -r kg_test_username=$1

  # cleanup the users table
  $HASURA_CURL_POST_COMMAND "{ \"query\": \"mutation { delete_kgraph_users(where: {username: {_eq: \\\"$kg_test_username\\\"}}) { affected_rows }}\" }" "$HASURA_GRAPHQL_ENDPOINT"

  # create an entry in the users table
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

  # add a topic
  TOPIC_ID_RESULT=$( $HASURA_CURL_POST_COMMAND "{ \"query\": \"mutation { insert_kgraph_topics(objects: {users_username: \\\"$kg_test_username\\\", name: \\\"$kg_test_topicname\\\"}) { returning { id } } }\" }" "$HASURA_GRAPHQL_ENDPOINT" )
  printf "added topic: %s with id: %s\n" "$kg_test_topicname" "$TOPIC_ID_RESULT"

  # get the topic by ID
  TOPIC_ID=$( echo "$TOPIC_ID_RESULT" | jq .data.insert_kgraph_topics.returning[0].id | tr -d '"' )
  TOPICNAME_RESULT=$( $HASURA_CURL_POST_COMMAND "{\"query\": \"query { kgraph_topics(where: {id: {_eq: \\\"$TOPIC_ID\\\" }}) { name }}\" }" "$HASURA_GRAPHQL_ENDPOINT" )
  printf "get topic: %s with id: %s\n" "$TOPICNAME_RESULT" "$TOPIC_ID"

  TOPICNAME_NAME=$( echo "$TOPICNAME_RESULT" | jq .data.kgraph_topics[0].name | tr -d '"' )
  # verify that TOPICNAME matches TOPICNAME_NAME
  if [[ "$kg_test_topicname" != "$TOPICNAME_NAME" ]]; then
    exit 1;
  fi

  # add label for user
  LABEL_ID_RESULT=$( $HASURA_CURL_POST_COMMAND "{ \"query\": \"mutation { insert_kgraph_labels(objects: {users_username: \\\"$kg_test_username\\\", title: \\\"$kg_test_labelname\\\"}) { returning { id } } }\" }" "$HASURA_GRAPHQL_ENDPOINT" )
  printf "added label: %s with id: %s\n" "$kg_test_labelname" "$LABEL_ID_RESULT"

  # get the label ID
  LABEL_ID=$( echo "$LABEL_ID_RESULT" | jq .data.insert_kgraph_labels.returning[0].id | tr -d '"' )

  # add the topic - label relation
  LABEL_TOPIC_ID_RESULT=$( $HASURA_CURL_POST_COMMAND "{ \"query\": \"mutation { insert_kgraph_topics_labels(objects: {labels_id: \\\"$LABEL_ID\\\", topics_id: \\\"$TOPIC_ID\\\"}) { returning { id } } }\" }" "$HASURA_GRAPHQL_ENDPOINT" )
  printf "added topic %s - label %s relation with id: %s\n" "$TOPIC_ID" "$LABEL_ID" "$LABEL_TOPIC_ID_RESULT"

  LABEL_TOPIC_ID=$( echo "$LABEL_TOPIC_ID_RESULT" | jq .data.insert_kgraph_topics_labels.returning[0].id | tr -d '"' )
  if [[ "$LABEL_TOPIC_ID" -lt 1 ]]; then
    printf "error: label - topic relation id [%s] not matching expected value!" "$LABEL_TOPIC_ID"
    exit 1;
  fi
}

function test_add_existing_topic () {

  if [[ $# -ne 1 ]]; then
    printf "error - test_add_topic() - wrong input parameters - expected username\n"
    exit 1
  fi

  local -r kg_test_username=$1

  # 1. add a duplicate topic
  TOPIC_ID_RESULT=$( $HASURA_CURL_POST_COMMAND "{ \"query\": \"mutation { insert_kgraph_topics(objects: {users_username: \\\"$kg_test_username\\\", name: \\\"$kg_test_topicname\\\"}) { returning { id } } }\" }" "$HASURA_GRAPHQL_ENDPOINT" )
  printf "added topic: %s with id: %s\n" "$kg_test_topicname" "$TOPIC_ID_RESULT"

  # 2. check for error
  ERROR=$( echo "$TOPIC_ID_RESULT" | jq .errors[0].extensions.code | tr -d '"' )
  if [[ "constraint-violation" != "$ERROR" ]]; then
    printf "failed check added duplicate topic: %s with message: %s\n" "$kg_test_topicname" "$TOPIC_ID_RESULT"
    exit 1;
  fi
}

# test adding same topic for multiple users
function test_add_topics () {
  for i in {1..2}
  do
    test_add_topic "ci_test${i}"
    # test adding a second time an existing topic => expected an error
    test_add_existing_topic "ci_test${i}"
  done
}

function test_drop_all_data () {
  # 0. cleanup the users table => cascade on topics
  $HASURA_CURL_POST_COMMAND "{ \"query\": \"mutation { delete_kgraph_users(where: {}) { affected_rows }}\" }" "$HASURA_GRAPHQL_ENDPOINT"
}

function test_check_ci_topics () {
  for i in {1..2}
  do
    test_check_ci_topic "ci_test${i}"
  done
}

function test_check_ci_topic () {

  if [[ $# -ne 1 ]]; then
    printf "error - test_add_topic() - wrong input parameters - expected username\n"
    exit 1
  fi

  local -r kg_test_username=$1

  TOPICID_RESULT=$( $HASURA_CURL_POST_COMMAND "{\"query\": \"query { kgraph_topics(where: {users_username: {_eq: \\\"$kg_test_username\\\" }, name: {_eq: \\\"$kg_test_topicname\\\"}}) { id }}\" }" "$HASURA_GRAPHQL_ENDPOINT" )
  printf "get topic: %s with name: %s\n" "$TOPICID_RESULT" "$kg_test_topicname"
  TOPICID=$( echo "$TOPICID_RESULT" | jq .data.kgraph_topics[0].id | tr -d '"' )

  if [[ ! "$TOPICID" ]]; then
    printf "error: topic id not found!!"
    exit 1;
  fi
}